class AddIndexCommits < ActiveRecord::Migration[5.1]
  def change
    add_index :commits, :resource_type
    add_index :commits, :resource_id
  end
end
