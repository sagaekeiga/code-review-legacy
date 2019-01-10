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

class RevieweeOrg < ApplicationRecord
  acts_as_paranoid
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  belongs_to :org
  belongs_to :reviewee

  # -------------------------------------------------------------------------------
  # Enumerables
  # -------------------------------------------------------------------------------
  # 役割
  #
  # - owner  : オーナー・所有者
  # - member : メンバー・所属者
  #
  enum role: {
    owner:  1000,
    member: 2000
  }
  # -------------------------------------------------------------------------------
  # Attributes
  # -------------------------------------------------------------------------------
  attribute :role, default: roles[:member]
end
