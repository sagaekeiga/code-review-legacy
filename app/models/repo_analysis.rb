# == Schema Information
#
# Table name: repo_analyses
#
#  id                 :bigint(8)        not null, primary key
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  repo_id            :bigint(8)
#  static_analysis_id :bigint(8)
#
# Indexes
#
#  index_repo_analyses_on_repo_id             (repo_id)
#  index_repo_analyses_on_static_analysis_id  (static_analysis_id)
#

class RepoAnalysis < ApplicationRecord
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  belongs_to :repo
  belongs_to :static_analysis
end
