# == Schema Information
#
# Table name: reviews
#
#  id          :bigint(8)        not null, primary key
#  body        :text
#  deleted_at  :datetime
#  event       :integer
#  reason      :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  commit_id   :string
#  pull_id     :bigint(8)
#  remote_id   :bigint(8)
#  reviewer_id :bigint(8)
#
# Indexes
#
#  index_reviews_on_deleted_at   (deleted_at)
#  index_reviews_on_pull_id      (pull_id)
#  index_reviews_on_reviewer_id  (reviewer_id)
#
# Foreign Keys
#
#  fk_rails_...  (pull_id => pulls.id)
#  fk_rails_...  (reviewer_id => reviewers.id)
#

require 'rails_helper'

RSpec.describe Review, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
