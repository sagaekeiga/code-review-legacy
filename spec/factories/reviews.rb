# == Schema Information
#
# Table name: reviews
#
#  id         :bigint(8)        not null, primary key
#  body       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  pull_id    :bigint(8)
#  remote_id  :bigint(8)
#  user_id    :bigint(8)
#
# Indexes
#
#  index_reviews_on_pull_id  (pull_id)
#  index_reviews_on_user_id  (user_id)
#

FactoryBot.define do
  factory :review do
    
  end
end
