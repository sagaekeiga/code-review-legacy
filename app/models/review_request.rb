# == Schema Information
#
# Table name: review_requests
#
#  id         :bigint(8)        not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  pull_id    :bigint(8)
#  user_id    :bigint(8)
#
# Indexes
#
#  index_review_requests_on_pull_id  (pull_id)
#  index_review_requests_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (pull_id => pulls.id)
#  fk_rails_...  (user_id => users.id)
#

class ReviewRequest < ApplicationRecord
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  belongs_to :user
  belongs_to :pull
  # -------------------------------------------------------------------------------
  # Callbacks
  # -------------------------------------------------------------------------------
  after_commit :send_request_mail, on: %i(create)
  # -------------------------------------------------------------------------------
  # Validations
  # -------------------------------------------------------------------------------
  validates :user_id, uniqueness: { scope: :pull_id }
  private
  def send_request_mail
    UsersMailer.requests(pull_id, user_id).deliver
  end
end
