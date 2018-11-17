# == Schema Information
#
# Table name: review_comment_trees
#
#  id         :bigint(8)        not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  comment_id :bigint(8)
#  reply_id   :bigint(8)
#
# Indexes
#
#  index_review_comment_trees_on_comment_id  (comment_id)
#  index_review_comment_trees_on_reply_id    (reply_id)
#

FactoryBot.define do
  factory :review_comment_tree do
    
  end
end
