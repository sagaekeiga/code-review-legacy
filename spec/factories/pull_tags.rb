# == Schema Information
#
# Table name: pull_tags
#
#  id         :bigint(8)        not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  pull_id    :bigint(8)
#  tag_id     :bigint(8)
#
# Indexes
#
#  index_pull_tags_on_pull_id  (pull_id)
#  index_pull_tags_on_tag_id   (tag_id)
#

FactoryBot.define do
  factory :pull_tag do
    
  end
end
