require 'httparty'

headers = {
  'User-Agent': 'Mergee',
  'Accept': 'application/vnd.github.machine-man-preview'
}

body = {
  'body': 'Me too'
}

res = HTTParty.post 'https://api.github.com/repos/sagaekeiga/github-api-sample/issues/43/comments', body: body, headers: headers
p res
