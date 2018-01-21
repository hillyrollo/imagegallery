module SankakuChannel
  def self.get_image_properties(url)
    image_regex = /<a\ id=image-link\ class=sample\ href=\"\/\/(.*)\?.*\">/

    resp = HTTParty.get(url)

    doc = Nokogiri::HTML(resp.body)
    image_path = nil

    doc.css('a').each do |a|
      next if a.attributes['id'].nil?
      next unless a.attributes['id'].value == 'image-link'
      link_type = a.attributes['class'].value

      if link_type == 'sample'
        image_path = a.attributes['href'].value
      elsif link_type == 'full'
        image_path = a.css('img').first.attributes['src'].value
      end

      image_path = image_path.split('//').last.split('?').first
      break
    end

    return nil, {} if image_path.nil?
    url = "https://#{image_path}"

    genres = []
    artists = []
    characters = []
    copyrights = []
    doc.css('li').each do |n|
      next unless n.attributes['class']
      tag_type = n.attributes['class'].value
      next unless tag_type.starts_with?('tag-type-')

      tag_value = n.children.first.attributes['href'].value.split('=').last

      artists << URI.unescape(tag_value) if tag_type == 'tag-type-artist'
      copyrights << URI.unescape(tag_value) if tag_type == 'tag-type-copyright'
      characters << URI.unescape(tag_value) if tag_type == 'tag-type-character'
      genres << URI.unescape(tag_value) if tag_type == 'tag-type-general'
    end

    tag_hash = {
      'artists' => artists,
      'copyrights' => copyrights,
      'characters' => characters,
      'genres' => genres
    }
    return url, tag_hash
  end
end
