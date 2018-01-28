class ImagesController < ApplicationController
  skip_before_action :verify_authenticity_token, :only => [:create]
  autocomplete :tag, :name, class_name: 'ActsAsTaggableOn::Tag'

  def index
    @images = Image.order("RANDOM()").first(35)
    @artists_hash, @characters_hash, @genres_hash, @series_hash = ImagesHelper.generate_tag_counts(@images)
  end

  def latest
    @images = Image.last(35).reverse
    @artists_hash, @characters_hash, @genres_hash, @series_hash = ImagesHelper.generate_tag_counts(@images)
  end

  def random_tag
    tag = Image.all_tags.order('RANDOM()').first.name
    redirect_to controller: 'images', action: 'search', search: tag
  end

  def random_image
    image = Image.order("RANDOM()").first
    redirect_to(post_path(image))
  end

  def search
    params[:search].downcase!
    if params[:search].nil?
      redirect_to root_path
      return
    end
    @images = Image.tagged_with(params[:search].split(' '))
    return if @images.length < 1
    @title = params[:search].split(' ').join(' + ')
    @artists_hash, @characters_hash, @genres_hash, @series_hash = ImagesHelper.generate_tag_counts(@images)
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

  def show
    @image = Image.find_by id: params[:id]
    @artists_hash, @characters_hash, @genres_hash, @series_hash = ImagesHelper.generate_tag_counts([@image])
  end

  def check
     i = Image.find_by source_url: params[:url]
     if i.nil?
       render plain: 'false'
       return
     end
     render plain: 'true'
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

    image_name = File.basename(url)
    # Make sure we don't already have the image
    if File.exist?("#{Settings.image_directory}/#{image_name}")
      render json: { status: 409, message: 'image already exists' }, status: 409
      return
    end

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
