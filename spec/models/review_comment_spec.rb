# == Schema Information
#
# Table name: review_comments
#
#  id                :bigint(8)        not null, primary key
#  body              :text
#  deleted_at        :datetime
#  github_created_at :datetime
#  github_updated_at :datetime
#  path              :string
#  position          :integer
#  status            :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  changed_file_id   :bigint(8)
#  github_id         :integer
#  in_reply_to_id    :integer
#  review_id         :bigint(8)
#  reviewer_id       :bigint(8)
#
# Indexes
#
#  index_review_comments_on_changed_file_id  (changed_file_id)
#  index_review_comments_on_deleted_at       (deleted_at)
#  index_review_comments_on_review_id        (review_id)
#  index_review_comments_on_reviewer_id      (reviewer_id)
#
# Foreign Keys
#
#  fk_rails_...  (changed_file_id => changed_files.id)
#  fk_rails_...  (review_id => reviews.id)
#  fk_rails_...  (reviewer_id => reviewers.id)
#

require 'rails_helper'

RSpec.describe ReviewComment, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
