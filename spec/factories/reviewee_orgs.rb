# == Schema Information
#
# Table name: reviewee_orgs
#
#  id          :bigint(8)        not null, primary key
#  deleted_at  :datetime
#  role        :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  org_id      :bigint(8)
#  reviewee_id :bigint(8)
#
# Indexes
#
#  index_reviewee_orgs_on_deleted_at   (deleted_at)
#  index_reviewee_orgs_on_org_id       (org_id)
#  index_reviewee_orgs_on_reviewee_id  (reviewee_id)
#

FactoryBot.define do
  factory :reviewee_org do
    
  end
end
