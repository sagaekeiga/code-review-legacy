class RemoveAnalysisFromRepo < ActiveRecord::Migration[5.2]
  def up
    remove_column :repos, :analysis, :boolean, default: false
  end

  def down
    add_column :repos, :analysis, :boolean, default: false
  end
end
