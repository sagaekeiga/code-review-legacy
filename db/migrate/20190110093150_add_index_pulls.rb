class AddIndexPulls < ActiveRecord::Migration[5.1]
  def change
    add_index :pulls, :resource_type
    add_index :pulls, :resource_id
  end
end
