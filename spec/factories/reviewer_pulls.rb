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

FactoryBot.define do
  factory :reviewer_pull do
    
  end
end
