require 'httparty'

headers = {
  'User-Agent': 'Mergee',
  'Accept': 'application/vnd.github.machine-man-preview'
}

body = {
  'body': 'Me too'
}

res = HTTParty.get 'https://api.github.com/repos/sagaekeiga/push-request-v2/stats/contributors', headers: headers
puts JSON.pretty_generate(JSON.load(res.body))
