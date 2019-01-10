class AddIndexReviews < ActiveRecord::Migration[5.1]
  def change
    add_index :reviews, :commit_id
  end
end
