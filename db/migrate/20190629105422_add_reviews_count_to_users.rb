class AddReviewsCountToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :reviews_count, :integer
  end
end
