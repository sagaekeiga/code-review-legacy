# == Schema Information
#
# Table name: commits
#
#  id             :bigint(8)        not null, primary key
#  committed_date :string
#  committer_name :string
#  deleted_at     :datetime
#  message        :string
#  resource_type  :string
#  sha            :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  pull_id        :bigint(8)
#  resource_id    :integer
#
# Indexes
#
#  index_commits_on_deleted_at     (deleted_at)
#  index_commits_on_pull_id        (pull_id)
#  index_commits_on_resource_id    (resource_id)
#  index_commits_on_resource_type  (resource_type)
#
# Foreign Keys
#
#  fk_rails_...  (pull_id => pulls.id)
#

require 'rails_helper'

RSpec.describe Commit, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
