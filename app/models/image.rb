class Image < ApplicationRecord
  acts_as_taggable # Alias for acts_as_taggable_on :tags
  acts_as_taggable_on :artists, :genres, :characters, :copyrights, :mediums

  def tag_summary
    (artist_list + character_list + genre_list + copyright_list + medium_list).uniq
  end

  def thumbnail_path
    file = filename.split '.'
    file[1] = 'png'
    "thumbs/#{file.join '.'}"
  end

  def file_path
    "#{Settings.image_directory}/#{filename}"
  end

  # Current supported video types are mp4 and webm
  def is_video?
    ['mp4', 'webm'].include? extension
  end

  def extension
    File.extname(filename).split('.').last
  end

  def update_tags
    url, tags = SankakuChannel.get_image_properties(source_url)
    return if url.nil?
    return if tags == {}

    self.artist_list = tags['artists']
    self.genre_list = tags['genres']
    self.character_list = tags['characters']
    self.copyright_list = tags['copyrights']
    self.medium_list = tags['mediums']

    save
  end
end
