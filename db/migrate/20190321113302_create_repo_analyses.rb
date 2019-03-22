class CreateRepoAnalyses < ActiveRecord::Migration[5.2]
  def change
    create_table :repo_analyses do |t|
      t.belongs_to :repo
      t.belongs_to :static_analysis
      t.timestamps
    end
  end
end
