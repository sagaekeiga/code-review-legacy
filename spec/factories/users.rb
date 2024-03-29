# == Schema Information
#
# Table name: users
#
#  id                     :bigint(8)        not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  reviews_count          :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'hogehoge' }
    password_confirmation { 'hogehoge' }
    after(:build) do |user|
      user.github_account ||= build(:users_github_account,
        user: user
      )
    end
    trait :with_user_tags do
      after(:create) do |user|
        create_list(:user_tag, 1, user: user)
      end
    end
  end
end
