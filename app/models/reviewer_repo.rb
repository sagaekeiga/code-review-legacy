# == Schema Information
#
# Table name: reviewer_repos
#
#  id          :bigint(8)        not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  repo_id     :bigint(8)
#  reviewer_id :bigint(8)
#
# Indexes
#
#  index_reviewer_repos_on_repo_id      (repo_id)
#  index_reviewer_repos_on_reviewer_id  (reviewer_id)
#

class ReviewerRepo < ApplicationRecord
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  belongs_to :repo
  belongs_to :reviewer
end
