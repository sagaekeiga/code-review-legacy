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

class StaticAnalysis < ApplicationRecord
  # -------------------------------------------------------------------------------
  # Validations
  # -------------------------------------------------------------------------------
  validates :title, presence: true, uniqueness: true
  # -------------------------------------------------------------------------------
  # Enumerables
  # -------------------------------------------------------------------------------
  # 検索名
  #
  # - rails_best_practices: Rails Best Practices
  #
  enum search_name: {
    rails_best_practices: 1000
  }
end
