class ImagesController < ApplicationController
  skip_before_action :verify_authenticity_token, :only => [:create, :create_v2]
  autocomplete :tag, :name, class_name: 'ActsAsTaggableOn::Tag'

  def index
    @images = Image.offset(rand(Image.count) - 25).first(25).shuffle
    @artists_hash, @characters_hash, @genres_hash, @series_hash, @mediums_hash, @models_hash = ImagesHelper.generate_tag_counts(@images)
  end

  def latest
    count = params[:count]&.to_i || 25
    @images = Image.last(count).reverse
    @artists_hash, @characters_hash, @genres_hash, @series_hash, @mediums_hash, @models_hash = ImagesHelper.generate_tag_counts(@images)
  end

  def random_tag
    tag = Image.all_tags.offset(rand(Image.all_tags.count)).first.name
    redirect_to controller: 'images', action: 'search', search: tag
  end

  def random_image
    image = Image.offset(rand(Image.count)).first
    redirect_to(post_path(image))
  end

  def random_images
    count = params[:count]&.to_i || 150
    @images = Image.all.sample(count)
    @artists_hash, @characters_hash, @genres_hash, @series_hash, @mediums_hash, @models_hash = ImagesHelper.generate_tag_counts(@images)
  end

  def search
    params[:search].downcase!
    if params[:search].nil?
      redirect_to root_path
      return
    end
    @images = Image.tagged_with(params[:search].split(' ')).reverse
    return if @images.length < 1

    tags = params[:search].split(' ')
    if tags.length == 1
      @title = "#{tags.first} (#{Image.all_tags.find_by(name: tags.first).taggings_count})"
    else
      tags.each_with_index do |t, i|
        tags[i] = "#{tags[i]}(#{Image.all_tags.find_by(name: tags[i]).taggings_count})"
      end
      @title = tags.join(' + ')
      @title << " = #{@images.length}"
    end
    @artists_hash, @characters_hash, @genres_hash, @series_hash, @mediums_hash, @models_hash = ImagesHelper.generate_tag_counts(@images)
  end

  def artists
    @list = Image.artist_counts.order(:name)
  end

  def genres
    @list = Image.genre_counts.order(:name)
  end

  def characters
    @list = Image.character_counts.order(:name)
  end

  def mediums
    @list = Image.medium_counts.order(:name)
  end

  def models
    @list = Image.model_counts.order(:name)
  end

  def show
    @images = [Image.find_by(id: params[:id])]
    @image = @images.first
    @artists_hash, @characters_hash, @genres_hash, @series_hash, @mediums_hash, @models_hash = ImagesHelper.generate_tag_counts([@image])
  end

  def check
     i = Image.find_by source_url: params[:url]
     if i.nil?
       render plain: ''
       return
     end
     render plain: params[:url].split('/').last
  end

  def create
    if !Image.find_by(source_url: params[:url]).nil?
      render json: { status: 409, message: 'image already exists' }, status: 409
      return
    end
    # Only supporting Sankaku for now
    url, tags = SankakuChannel.get_image_properties(params[:url])
    if url.nil?
      render json: { status: 500, message: "Unable to get image from URL #{params[:url]}" }, status: 500
      return
    end

    image_name = File.basename(url.split('?').first)
    # Make sure we don't already have the image
    if File.exist?("#{Settings.image_directory}/#{image_name}")
      render json: { status: 409, message: 'image already exists' }, status: 409
      return
    end

    tags = ImagesHelper.sanitize_tags(tags)

    # Download image
    resp = HTTParty.get(url)
    puts resp.code
    if resp.code != 200
      render json: { status: 500, message: "Error downloading from #{params[:url]}, code: #{resp.code}" }, status: 500
      return
    end
    File.open("#{Settings.image_directory}/#{image_name}", 'wb') do |f|
      f.write(resp.body)
    end

    # Add to database
    image = Image.new
    image.filename = image_name
    image.source_url = params[:url]
    if image.is_video?
      v = FFMPEG::Movie.new("#{Settings.image_directory}/#{image_name}")
      image.width = v.width
      image.height = v.height
    else
      image.width, image.height = FastImage.size("#{Settings.image_directory}/#{image_name}")
    end

    image.artist_list = tags['artists']
    image.genre_list = tags['genres']
    image.character_list = tags['characters']
    image.copyright_list = tags['copyrights']
    image.medium_list = tags['mediums']
    image.model_list = tags['models']

    image = ImageProcessingHelper.scale_image(image) unless image.is_video?
    image.save

    # Create thumbnail
    if ThumbnailHelper.create_thumbnail("#{Settings.image_directory}/#{image_name}") != nil
      render json: { status: 500, message: "Error generating thumbnail" }, status: 500
      return
    end

    render json: { status: 200, message: 'success'}
  end

  def create_v2
    source_url = params[:source_url]
    tags = params[:tags]
    image_url = params[:image_url]

    if !Image.find_by(source_url: source_url).nil?
      render json: { status: 409, message: 'image already exists' }, status: 409
      return
    end

    image_name = File.basename(image_url.split('?').first)
    # Make sure we don't already have the image
    if File.exist?("#{Settings.image_directory}/#{image_name}")
      render json: { status: 409, message: 'image already exists' }, status: 409
      return
    end

    resp = HTTParty.get(image_url)
    if resp.code != 200
      render json: { status: 500, message: "Error downloading from #{params[:url]}, code: #{resp.code}" }, status: 500
      return
    end
    File.open("#{Settings.image_directory}/#{image_name}", 'wb') do |f|
      f.write(resp.body)
    end

    image = Image.new
    image.filename = image_name
    image.source_url = source_url
    if image.is_video?
      v = FFMPEG::Movie.new("#{Settings.image_directory}/#{image_name}")
      image.width = v.width
      image.height = v.height
    else
      image.width, image.height = FastImage.size("#{Settings.image_directory}/#{image_name}")
    end

    image.artist_list = tags['artist']
    image.genre_list = tags['general']
    image.character_list = tags['character']
    image.copyright_list = tags['copyright']
    image.medium_list = tags['medium']
    image.model_list = tags['model']

    image = ImageProcessingHelper.scale_image(image) unless image.is_video?
    image.save

    # Create thumbnail
    if ThumbnailHelper.create_thumbnail("#{Settings.image_directory}/#{image_name}") != nil
      render json: { status: 500, message: "Error generating thumbnail" }, status: 500
      return
    end

    render json: { status: 200, message: 'success'}
  end
end
