require 'httparty'

headers = {
  'User-Agent': 'Mergee',
  'Accept': 'application/vnd.github.mercy-preview+json'
}

Skill.each do |skill|
  puts skill
  res = HTTParty.get "https://api.github.com/search/repositories?q=#{skill}", headers: headers
  res.each do |re|
    puts re.class
  end
end
