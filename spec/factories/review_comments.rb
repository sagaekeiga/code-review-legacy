# == Schema Information
#
# Table name: review_comments
#
#  id              :bigint(8)        not null, primary key
#  body            :text
#  deleted_at      :datetime
#  event           :integer
#  path            :string
#  position        :integer
#  read            :boolean
#  status          :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  changed_file_id :bigint(8)
#  in_reply_to_id  :bigint(8)
#  remote_id       :bigint(8)
#  review_id       :bigint(8)
#  reviewer_id     :bigint(8)
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

FactoryBot.define do
  factory :review_comment do
    
  end
end
