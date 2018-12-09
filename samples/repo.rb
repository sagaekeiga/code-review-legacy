require 'httparty'
require 'base64'
require 'zip'
require 'open-uri'

headers = {
  'User-Agent': 'Mergee'
}

res = HTTParty.get 'https://github.com/sagaekeiga/github-api-sample/archive/master.zip'
puts res.body
Zip::InputStream.open(StringIO.new(res.body)) do |io|
  while entry = io.get_next_entry
    puts "/* #{entry.name} */"
    puts io.read
    # parse_zip_content io.read
  end
end
