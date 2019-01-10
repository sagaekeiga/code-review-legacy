class AddIndexNotifications < ActiveRecord::Migration[5.1]
  def change
    add_index :notifications, :resource_type
    add_index :notifications, :resource_id
  end
end
