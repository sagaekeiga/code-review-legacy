xml.instruct! :xml, version: '1.0'
xml.rss('version': '2.0', 'xmlns:dc': 'http://purl.org/dc/elements/1.1/') do
  xml.channel do
    xml.title Settings.meta.site.name
    xml.description Settings.description
    xml.link Settings.web.url
    @pulls.each do |pull|
      xml.item do
        xml.title pull.title
        xml.description pull.body.gsub(/[\r\n]/, '')
        xml.pubDate pull.updated_at.rfc2822
        xml.guid pull.remote_url
        xml.link pull.remote_url
      end
    end
  end
end
