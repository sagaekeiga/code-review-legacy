# == Schema Information
#
# Table name: reviewee_tags
#
#  id          :bigint(8)        not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  reviewee_id :bigint(8)
#  tag_id      :bigint(8)
#
# Indexes
#
#  index_reviewee_tags_on_reviewee_id  (reviewee_id)
#  index_reviewee_tags_on_tag_id       (tag_id)
#

FactoryBot.define do
  factory :reviewee_tag do
    
  end
end
