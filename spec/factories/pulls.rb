# == Schema Information
#
# Table name: pulls
#
#  id                :bigint(8)        not null, primary key
#  base_label        :string
#  body              :string
#  deleted_at        :datetime
#  head_label        :string
#  number            :integer
#  remote_created_at :datetime
#  resource_type     :string
#  status            :integer
#  title             :string
#  token             :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  remote_id         :integer
#  repo_id           :bigint(8)
#  resource_id       :integer
#
# Indexes
#
#  index_pulls_on_deleted_at  (deleted_at)
#  index_pulls_on_remote_id   (remote_id) UNIQUE
#  index_pulls_on_repo_id     (repo_id)
#
# Foreign Keys
#
#  fk_rails_...  (repo_id => repos.id)
#

FactoryBot.define do
  factory :pull do
    
  end
end
