# == Schema Information
#
# Table name: pulls
#
#  id                :bigint(8)        not null, primary key
#  body              :string
#  number            :integer          not null
#  remote_created_at :datetime         not null
#  status            :integer          not null
#  title             :string
#  token             :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  remote_id         :integer          not null
#  repo_id           :bigint(8)
#  user_id           :bigint(8)
#
# Indexes
#
#  index_pulls_on_remote_id  (remote_id) UNIQUE
#  index_pulls_on_repo_id    (repo_id)
#  index_pulls_on_user_id    (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (repo_id => repos.id)
#

require 'rails_helper'

RSpec.describe Pull, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
