class CreateNotifications < ActiveRecord::Migration[5.1]
  def change
    create_table :notifications do |t|
      t.belongs_to :reviewer
      t.belongs_to :pull
      t.integer :resource_id
      t.string  :resource_type
      t.timestamps
    end
  end
end
