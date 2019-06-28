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
  end
end