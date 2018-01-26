module ImageProcessingHelper
  # Create thumbnail, add to db, get tags, and move to images directory
  def self.process(image, images_directory, thumbnail_directory)
    puts "Scanning image #{image}"
    # Add to DB, if needed
    unless image_in_db?(image)
      puts 'No matching image in database, adding'
      i = Image.new
      i.filename = File.basename(image)
      id = ImageDimension.new(image)

      id = scale_image(id)
      i.width = id.width
      i.height = id.height

      url, tags = get_info(image)

      if tags.nil?
        puts 'nil tags, skipping'
        FileUtils.move(image, "#{Settings.processing_directory}/not_found/#{File.basename(image)}")
        return
      end
      i.source_url = tags['post_url']

      i.artist_list = tags['artists']
      i.genre_list = tags['genres']
      i.character_list = tags['characters']
      i.copyright_list = tags['copyrights']

      i.save

      # Generate thumbnail
      create_thumbnail(image, thumbnail_directory)

      # Move image to images directory, clean up original
      FileUtils.move(image, "#{images_directory}/#{File.basename(image)}") unless File.dirname(image) == images_directory
      return
    end
    puts 'Image already in database, skipping and cleaning up'
    File.delete(image)
  end

  # Create a thumbnail of the given image in the thumbnail directory provided
  def self.create_thumbnail(image_path, thumbnail_directory)
    return if File.exist? "#{thumbnail_directory}/#{File.basename(image_path)}"
    puts "Creating thumbnail for #{image_path}"
    `convert -thumbnail 180x180 -gravity center -background white -extent 180x180 #{image_path} #{thumbnail_directory}/#{File.basename(file_path).split('.').first}.png`
    $?.to_i
  end

  def self.get_info(image_path)
    md5 = Digest::MD5.file(image_path)
    SankakuChannel.get_image_properties_by_file(image_path)
    # # Try to find a source
    # resp = BooruSearch.file_search(image)
    # return nil if resp == []
    # resp = resp.first
    # provider = resp['source']
    #
    # url = ''
    # tags = {}
    # if provider == 'SankakuComplex'
    #   url, tags = SankakuChannel.get_image_properties(resp['page'])
    # elsif provider == 'Danbooru'
    #   url, tags = Danbooru::Posts.get_image_properties(resp['page'])
    # end
    #
    # return nil, nil if tags == {}
    # # resp = Danbooru::Posts.get_by_local_file(image)
    # # return nil if resp.nil?
    # return url, tags
  end

  def self.image_in_db?(image_path)
    basename = File.basename(image_path)
    !Image.find_by(filename: basename).nil?
  end

  def self.scale_image(image)
    if image.width < 1920 && image.height < 1080
      sf = scale_factor(image.width.to_f, image.height.to_f)
      image.width *= sf
      image.height *= sf
    end
    return image
  end

  def self.scale_factor(w,h)
    scale_factor = 1.0
    # Figure out which dimension we can scale on
    scale_factor_w = 1 + (1920.0 - w)/w
    scale_factor_h = 1 + (1080.0 - h)/h
    if scale_factor_w > scale_factor_h
      scale_factor = scale_factor_h
    else
      scale_factor = scale_factor_w
    end
    return scale_factor
  end
end
