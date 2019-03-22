# == Schema Information
#
# Table name: static_analyses
#
#  id          :bigint(8)        not null, primary key
#  search_name :integer
#  title       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'rails_helper'

RSpec.describe StaticAnalysis, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
