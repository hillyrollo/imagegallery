class Image < ApplicationRecord
  acts_as_taggable # Alias for acts_as_taggable_on :tags
  acts_as_taggable_on :artists, :genres, :characters, :copyrights

  def tag_summary
    (artist_list + character_list + genre_list + copyright_list).uniq
  end

  def thumbnail_path
    "thumbs/#{filename}"
  end

  def file_path
    "#{Settings.image_directory}/#{filename}"
  end
end
