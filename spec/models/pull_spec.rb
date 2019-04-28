# == Schema Information
#
# Table name: pulls
#
#  id                :bigint(8)        not null, primary key
#  addtions          :integer
#  base_label        :string
#  body              :string
#  deleted_at        :datetime
#  deletions         :integer
#  head_label        :string
#  number            :integer          not null
#  remote_created_at :datetime         not null
#  resource_type     :string
#  status            :integer          not null
#  title             :string
#  token             :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  remote_id         :integer          not null
#  repo_id           :bigint(8)
#  resource_id       :integer
#
# Indexes
#
#  index_pulls_on_deleted_at     (deleted_at)
#  index_pulls_on_remote_id      (remote_id) UNIQUE
#  index_pulls_on_repo_id        (repo_id)
#  index_pulls_on_resource_id    (resource_id)
#  index_pulls_on_resource_type  (resource_type)
#
# Foreign Keys
#
#  fk_rails_...  (repo_id => repos.id)
#

require 'rails_helper'

RSpec.describe Pull, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
