class AddAnalysisToRepos < ActiveRecord::Migration[5.2]
  def change
    add_column :repos, :analysis, :boolean, default: false
  end
end
