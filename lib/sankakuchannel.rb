module SankakuChannel
  def self.get_image_properties_by_file(file)
    md5 = Digest::MD5.file(file)
    id = get_id_by_md5(md5)
    return nil, nil if id.nil?

    get_image_properties("https://chan.sankakucomplex.com/post/show/#{id}")
  end

  def self.get_id_by_md5(md5)
    url = "https://chan.sankakucomplex.com/?tags=md5:#{md5}"
    resp = HTTParty.get url
    return nil if resp.code != 200

    doc = Nokogiri::HTML(resp.body)

    # Find ID
    thumbs = doc.css('span.thumb')
    return nil if thumbs.length < 1

    id = thumbs.first.attributes['id'].value
    id.gsub!(/\D/, '')
  end

  def self.get_image_properties(url)
    post_url = url
    image_regex = /<a\ id=image-link\ class=sample\ href=\"\/\/(.*)\?.*\">/

    resp = HTTParty.get(url)

    doc = Nokogiri::HTML(resp.body)
    image_path = nil

    if !doc.css('video').empty?
      image_path = doc.css('video').first['src'].split('?').first
    else
      doc.css('a').each do |a|
        next if a.attributes['id'].nil?
        next unless a.attributes['id'].value == 'image-link'
        link_type = a.attributes['class'].value

        if link_type == 'sample'
          image_path = a.attributes['href'].value
        elsif link_type == 'full'
          image_path = a.css('img').first.attributes['src'].value
        end

        image_path = image_path.split('?').first
        break
      end
    end

    return nil, {} if image_path.nil?
    url = "https:#{image_path}"

    genres = []
    artists = []
    characters = []
    copyrights = []
    mediums = []
    doc.css('li').each do |n|
      next unless n.attributes['class']
      tag_type = n.attributes['class'].value
      next unless tag_type.starts_with?('tag-type-')

      tag_value = n.children.first.attributes['href'].value.split('=').last

      artists << URI.unescape(tag_value) if tag_type == 'tag-type-artist'
      copyrights << URI.unescape(tag_value) if tag_type == 'tag-type-copyright'
      characters << URI.unescape(tag_value) if tag_type == 'tag-type-character'
      genres << URI.unescape(tag_value) if tag_type == 'tag-type-general'
      mediums << URI.unescape(tag_value) if tag_type == 'tag-type-medium'
    end
    puts "mediums list: #{mediums}"
    tag_hash = {
      'artists' => artists,
      'copyrights' => copyrights,
      'characters' => characters,
      'genres' => genres,
      'mediums' => mediums,
      'post_url' => post_url
    }
    return url, tag_hash
  end
end
