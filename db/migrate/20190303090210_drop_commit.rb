class DropCommit < ActiveRecord::Migration[5.2]
  def up
    drop_table :commits
  end
  def down
    create_table :commits do |t|
      t.integer :resource_id
      t.string  :resource_type
      t.belongs_to :pull, foreign_key: true
      t.string :sha
      t.string :message
      t.string :committer_name
      t.string :committed_date
      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end