# == Schema Information
#
# Table name: reviewees_github_accounts
#
#  id           :bigint(8)        not null, primary key
#  access_token :string
#  avatar_url   :string
#  company      :string
#  deleted_at   :datetime
#  email        :string
#  login        :string
#  name         :string
#  nickname     :string
#  user_type    :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  owner_id     :bigint(8)
#  reviewee_id  :bigint(8)
#
# Indexes
#
#  index_reviewees_github_accounts_on_deleted_at   (deleted_at)
#  index_reviewees_github_accounts_on_reviewee_id  (reviewee_id)
#
# Foreign Keys
#
#  fk_rails_...  (reviewee_id => reviewees.id)
#

FactoryBot.define do
  factory :reviewees_github_account, class: 'Reviewees::GithubAccount' do
    reviewee nil
    avatar_url 'https://identicons.github.com/pronama.png'
    email { Faker::Internet.email }
    owner_id { Faker::Number.number(5) }
    login { Faker::Name.name }
  end
end
