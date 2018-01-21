module BooruSearch
  def self.file_search(path, provider = '')
    md5sum = Digest::MD5.file(path)
    md5_search(md5sum)
  end

  def self.md5_search(md5sum, provider = '')
    base_url = 'https://cure.ninja/booru/api/json/md5'

    resp = HTTParty.get("#{base_url}/#{md5sum}")

    return nil if resp.code != 200
    JSON.parse resp.body
    return [] if resp['success'] == false
    resp['results']
  end

  def self.filter_results(resp, providers)
    results = []
    resp.each do |res|
      results << res if providers.include? res['source']
    end
    results
  end

  def self.get_url(result)
    return URI.unescape(result['page'])
  end
end
