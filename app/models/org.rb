# == Schema Information
#
# Table name: orgs
#
#  id         :bigint(8)        not null, primary key
#  avatar_url :string
#  deleted_at :datetime
#  login      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  remote_id  :bigint(8)
#
# Indexes
#
#  index_orgs_on_deleted_at  (deleted_at)
#

class Org < ApplicationRecord
  acts_as_paranoid
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  has_many :reviewee_orgs, dependent: :destroy
  has_many :reviewees, through: :reviewee_orgs
  has_many :repos, as: :resource
  has_many :pulls, as: :resource
  # -------------------------------------------------------------------------------
  # Validations
  # -------------------------------------------------------------------------------
  validates :remote_id, presence: true, uniqueness: true
  validates :login, presence: true

  def reviewee_org_id(reviewee_id)
    reviewee_orgs.find_by(reviewee_id: reviewee_id).id
  end
end
