class CreateReviews < ActiveRecord::Migration[5.1]
  def change
    create_table :reviews do |t|
      t.belongs_to :pull, foreign_key: true
      t.belongs_to :reviewer, foreign_key: true
      t.bigint :remote_id
      t.text :body
      t.text :reason
      t.integer :event
      t.string :commit_id
      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
