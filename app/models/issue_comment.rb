# == Schema Information
#
# Table name: issue_comments
#
#  id         :bigint(8)        not null, primary key
#  body       :text
#  url        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  pull_id    :bigint(8)
#  remote_id  :integer
#
# Indexes
#
#  index_issue_comments_on_pull_id  (pull_id)
#
# Foreign Keys
#
#  fk_rails_...  (pull_id => pulls.id)
#

class IssueComment < ApplicationRecord
end
