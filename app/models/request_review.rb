# == Schema Information
#
# Table name: request_reviews
#
#  id         :bigint(8)        not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  pull_id    :bigint(8)
#  user_id    :bigint(8)
#
# Indexes
#
#  index_request_reviews_on_pull_id  (pull_id)
#  index_request_reviews_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (pull_id => pulls.id)
#  fk_rails_...  (user_id => users.id)
#

class RequestReview < ApplicationRecord
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  belongs_to :user
  belongs_to :pull
  # -------------------------------------------------------------------------------
  # Validations
  # -------------------------------------------------------------------------------
  validates :user_id, uniqueness: { scope: :pull_id }
end
