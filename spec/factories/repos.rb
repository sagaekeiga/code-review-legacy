# == Schema Information
#
# Table name: repos
#
#  id              :bigint(8)        not null, primary key
#  analysis        :boolean
#  deleted_at      :datetime
#  full_name       :string
#  name            :string
#  private         :boolean
#  resource_type   :string
#  template        :boolean
#  token           :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  installation_id :bigint(8)
#  remote_id       :integer
#  resource_id     :integer
#
# Indexes
#
#  index_repos_on_deleted_at     (deleted_at)
#  index_repos_on_resource_id    (resource_id)
#  index_repos_on_resource_type  (resource_type)
#

FactoryBot.define do
  factory :repo do
    reviewee nil
    full_name { Faker::Name.name }
    name { Faker::Name.first_name }
    private true
    remote_id { Faker::Number.number(6) }
  end
end
