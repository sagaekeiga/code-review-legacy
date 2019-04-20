# == Schema Information
#
# Table name: reviewers_profiles
#
#  id          :bigint(8)        not null, primary key
#  body        :text
#  company     :string
#  status      :integer
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

require 'rails_helper'

RSpec.describe Reviewers::Profile, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
