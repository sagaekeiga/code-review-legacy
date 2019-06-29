class CreateReviews < ActiveRecord::Migration[5.2]
  def change
    create_table :reviews do |t|
      t.belongs_to :user
      t.belongs_to :pull
      t.bigint :remote_id
      t.text :body
      t.timestamps
    end
  end
end
