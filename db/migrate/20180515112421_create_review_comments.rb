class CreateReviewComments < ActiveRecord::Migration[5.1]
  def change
    create_table :review_comments do |t|
      t.belongs_to :reviewer, foreign_key: true
      t.belongs_to :review, foreign_key: true
      t.belongs_to :changed_file, foreign_key: true
      t.text :body
      t.string :path
      t.integer :position
      t.bigint :in_reply_to_id
      t.bigint :remote_id
      t.integer :status
      t.integer :event
      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
