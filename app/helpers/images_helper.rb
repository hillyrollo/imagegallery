module ImagesHelper
  def self.generate_tag_counts(images)
    artists_hash = {}
    characters_hash = {}
    genres_hash = {}
    series_hash = {}

    images.each do |image|
      image.artists.each do |a|
        artists_hash[a.name] = a.taggings_count if artists_hash[a.name].nil?
      end
      image.characters.each do |c|
        characters_hash[c.name] = c.taggings_count if characters_hash[c.name].nil?
      end
      image.genres.each do |g|
        genres_hash[g.name] = g.taggings_count if genres_hash[g.name].nil?
      end
      image.copyrights.each do |c|
        series_hash[c.name] = c.taggings_count if series_hash[c.name].nil?
      end
    end

    return artists_hash.sort.to_h, characters_hash.sort.to_h, genres_hash.sort.to_h, series_hash.sort.to_h
  end
end
