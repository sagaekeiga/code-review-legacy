# == Schema Information
#
# Table name: user_tags
#
#  id         :bigint(8)        not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  tag_id     :bigint(8)
#  user_id    :bigint(8)
#
# Indexes
#
#  index_user_tags_on_tag_id   (tag_id)
#  index_user_tags_on_user_id  (user_id)
#

FactoryBot.define do
  factory :user_tag do
    user { nil }
    tag { Tag.where('id >= ?', [161, 198, 369].sample).first }
  end
end
