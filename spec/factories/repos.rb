# == Schema Information
#
# Table name: repos
#
#  id              :bigint(8)        not null, primary key
#  full_name       :string
#  name            :string
#  private         :boolean
#  token           :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  installation_id :bigint(8)
#  remote_id       :integer
#  user_id         :bigint(8)
#
# Indexes
#
#  index_repos_on_user_id  (user_id)
#

FactoryBot.define do
  factory :repo do
    user nil
    full_name { Faker::Name.name }
    name { Faker::Name.first_name }
    private true
    remote_id { Faker::Number.number(6) }
  end
end
