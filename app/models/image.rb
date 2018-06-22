class Image < ApplicationRecord
  acts_as_taggable # Alias for acts_as_taggable_on :tags
  acts_as_taggable_on :artists, :genres, :characters, :copyrights, :mediums, :models

  def tag_summary
    (artist_list + character_list + genre_list + copyright_list + medium_list + model_list).uniq
  end

  def asset_path
    "#{Settings.image_asset_prefix}#{filename}"
  end

  def thumbnail_path
    file = filename.split '.'
    file[1] = 'png'
    "#{Settings.image_asset_prefix}thumbs/#{file.join '.'}"
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
    self.model_list = tags['models']

    save
  end

  def self.untagged
    untagged = []
    self.all.each do |i|
      tag_sum =i.artist_list.length + i.genre_list.length + i.copyright_list.length + i.character_list.length + i.medium_list.length + i.model_list.length
      untagged << i if tag_sum == 0
    end
    untagged
  end
end
