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

require 'rails_helper'

RSpec.describe PullTag, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
