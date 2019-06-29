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

FactoryBot.define do
  factory :review_request do
    
  end
end
