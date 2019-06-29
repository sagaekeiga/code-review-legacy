# == Schema Information
#
# Table name: users_github_accounts
#
#  id         :bigint(8)        not null, primary key
#  avatar_url :string
#  bio        :text
#  email      :string
#  name       :string
#  nickname   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  owner_id   :bigint(8)
#  user_id    :bigint(8)
#
# Indexes
#
#  index_users_github_accounts_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

FactoryBot.define do
  factory :users_github_account, class: 'Users::GithubAccount' do
    user { nil }
    avatar_url { 'https://identicons.github.com/pronama.png' }
    email { Faker::Internet.email }
    owner_id { Faker::Number.number(5) }
    nickname { Faker::Name.name }
    name { Faker::Name.name }
    bio { Faker::Lorem.sentence }
  end
end
