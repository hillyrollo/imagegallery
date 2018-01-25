require 'httparty'
require 'digest'
require 'fastimage'

class TagSet
  attr_accessor :artists, :tags, :characters, :copyrights
  def initialize(hash)
    @tags = hash['tag_string'].split(' ')
    @artists = hash['tag_string_artist'].split(' ')
    @copyrights = hash['tag_string_copyright'].split(' ')
    @characters = hash['tag_string_character'].split(' ')

    # Remove artists/characters tags from general tags
    @tags -= @artists
    @tags -= @characters
    @tags -= @copyrights
  end
end

class ImageDimension
  attr_accessor :width, :height
  def initialize(path)
    @width, @height = FastImage.size(path)
  end
end

module Danbooru
  module Danbooru::Posts
    def self.get_image_properties(url)
      orig_url = url
      post_id = url.split('/').last
      url = "https://danbooru.donmai.us/posts/#{post_id}.json"
      resp = HTTParty.get(url)

      resp = JSON.parse(resp.body)
      t = TagSet.new(resp)

      tag_hash = {
        'artists' => t.artists,
        'copyrights' => t.copyrights,
        'characters' => t.characters,
        'genres' => t.tags
      }

      # image_path = resp['file_url']
      # url = "https://danbooru.donmai.us#{image_path}"

      return orig_url, tag_hash
    end

    def self.get_by_id(id)
      JSON.parse HTTParty.get("https://danbooru.donmai.us/posts/#{id}.json").body
    end

    def self.get_by_md5(md5)
      id = get_id_by_md5(md5)
      return nil if id.nil?
      get_by_id()
    end

    def self.get_by_local_file(path)
      md5sum = Digest::MD5.file(path)
      get_by_md5(md5sum)
    end

    def self.get_id_by_md5(md5)
      resp = HTTParty.head("https://danbooru.donmai.us/posts.json?md5=#{md5}", follow_redirects: false)
      puts resp
      return nil if resp.code != 200
      resp.headers['location'].split('/').last
    end
  end
end
