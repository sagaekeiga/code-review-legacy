# == Schema Information
#
# Table name: user_orgs
#
#  id          :bigint(8)        not null, primary key
#  deleted_at  :datetime
#  role        :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  org_id      :bigint(8)
#  user_id :bigint(8)
#
# Indexes
#
#  index_user_orgs_on_deleted_at   (deleted_at)
#  index_user_orgs_on_org_id       (org_id)
#  index_user_orgs_on_user_id  (user_id)
#

FactoryBot.define do
  factory :user_org do
    
  end
end
