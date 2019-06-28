FactoryBot.define do
  factory :users_github_account, class: 'Users::GithubAccount' do
    user { nil }
    avatar_url { 'https://identicons.github.com/pronama.png' }
    email { Faker::Internet.email }
    owner_id { Faker::Number.number(5) }
    nickname { Faker::Name.name }
    name { Faker::Name.name }
  end
end