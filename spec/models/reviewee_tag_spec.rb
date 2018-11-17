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

require 'rails_helper'

RSpec.describe RevieweeTag, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
