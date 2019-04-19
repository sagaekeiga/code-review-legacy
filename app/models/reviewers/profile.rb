# == Schema Information
#
# Table name: reviewers_profiles
#
#  id          :bigint(8)        not null, primary key
#  body        :text
#  company     :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  reviewer_id :bigint(8)
#
# Indexes
#
#  index_reviewers_profiles_on_reviewer_id  (reviewer_id)
#
# Foreign Keys
#
#  fk_rails_...  (reviewer_id => reviewers.id)
#

class Reviewers::Profile < ApplicationRecord
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  belongs_to :reviewer
end
