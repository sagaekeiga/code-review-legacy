class CreatePulls < ActiveRecord::Migration[5.2]
  def change
    create_table :pulls do |t|
      t.belongs_to :repo, foreign_key: true
      t.belongs_to :user, foreign_key: true
      t.integer :remote_id, null: false
      t.integer :number, null: false
      t.string :title
      t.string :body
      t.integer :status, null: false
      t.datetime :remote_created_at, null: false
      t.timestamps
    end
    add_index :pulls, :remote_id, unique: true
  end
end
