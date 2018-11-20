class CreatePulls < ActiveRecord::Migration[5.1]
  def change
    create_table :pulls do |t|
      t.belongs_to :repo, foreign_key: true
      t.integer :resource_id
      t.string  :resource_type
      t.integer :remote_id, null: false
      t.integer :number, null: false
      t.string :title
      t.string :body
      t.integer :status, null: false
      t.string :token, null: false
      t.string :base_label
      t.string :head_label
      t.datetime :remote_created_at, null: false
      t.datetime :deleted_at, index: true
      t.timestamps
    end
    add_index :pulls, :remote_id, unique: true
  end
end
