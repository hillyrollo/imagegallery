module ImagesHelper
  def self.generate_tag_counts(images)
    artists_hash = {}
    characters_hash = {}
    genres_hash = {}
    series_hash = {}
    mediums_hash = {}
    models_hash = {}

    # Only generate tags for the first 20 images
    images = images.first(20)

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
      image.mediums.each do |m|
        mediums_hash[m.name] = m.taggings_count if mediums_hash[m.name].nil?
      end
      image.models.each do |m|
        models_hash[m.name] = m.taggings_count if models_hash[m.name].nil?
      end
    end

    return artists_hash.sort.to_h, characters_hash.sort.to_h, genres_hash.sort.to_h, series_hash.sort.to_h, mediums_hash.sort.to_h, models_hash.sort.to_h
  end

  def self.contains_bad_characters?(str)
    bad_char_regex = /[ÀÁÂÃÄÅàáâãäåĀāĂăĄąÇçĆćĈĉĊċČčÐðĎďĐđÈÉÊËèéêëĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħÌÍÎÏìíîïĨĩĪīĬĭĮįİıĴĵĶķĸĹĺĻļĽľĿŀŁłÑñŃńŅņŇňŉŊŋÒÓÔÕÖØòóôõöøŌōŎŏŐőŔŕŖŗŘřŚśŜŝŞşŠšſŢţŤťŦŧÙÚÛÜùúûüŨũŪūŬŭŮůŰűŲųŴŵÝýÿŶŷŸŹźŻżŽž]/
    str.match(bad_char_regex)
  end

  def sanitize_tags(tags)
    tags.keys.each do |k|
      tags[k].each do |tag|
        tags[k].delete(tag) if contains_bad_characters?(tag)
      end
    end
    tags
  end
end
