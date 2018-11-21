# == Schema Information
#
# Table name: orgs
#
#  id         :bigint(8)        not null, primary key
#  avatar_url :string
#  deleted_at :datetime
#  login      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  remote_id  :bigint(8)
#
# Indexes
#
#  index_orgs_on_deleted_at  (deleted_at)
#

require 'rails_helper'

RSpec.describe Org, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
