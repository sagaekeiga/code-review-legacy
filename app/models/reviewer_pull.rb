# == Schema Information
#
# Table name: reviewer_pulls
#
#  id          :bigint(8)        not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  pull_id     :bigint(8)
#  reviewer_id :bigint(8)
#
# Indexes
#
#  index_reviewer_pulls_on_pull_id      (pull_id)
#  index_reviewer_pulls_on_reviewer_id  (reviewer_id)
#

class ReviewerPull < ApplicationRecord
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  belongs_to :pull
  belongs_to :reviewer
  # -------------------------------------------------------------------------------
  # Validations
  # -------------------------------------------------------------------------------
  validates :pull_id, uniqueness: true
  validates :pull_id, uniqueness: { scope: :reviewer_id }
  # -------------------------------------------------------------------------------
  # Callbacks
  # -------------------------------------------------------------------------------
  after_create :send_mail, on: :create

  private

  def send_mail
    ReviewerPullMailer.repo_assign_mail(self).deliver_later(wait: 5.seconds)
  end
end
