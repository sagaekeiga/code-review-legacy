# == Schema Information
#
# Table name: reviewer_tags
#
#  id          :bigint(8)        not null, primary key
#  year        :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  reviewer_id :bigint(8)
#  tag_id      :bigint(8)
#
# Indexes
#
#  index_reviewer_tags_on_reviewer_id  (reviewer_id)
#  index_reviewer_tags_on_tag_id       (tag_id)
#

class ReviewerTag < ApplicationRecord
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  belongs_to :tag
  belongs_to :reviewer
  # -------------------------------------------------------------------------------
  # Delegations
  # -------------------------------------------------------------------------------
  delegate :name, to: :tag
end
