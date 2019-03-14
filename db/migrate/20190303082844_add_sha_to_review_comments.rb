class AddShaToReviewComments < ActiveRecord::Migration[5.2]
  def change
    add_column :review_comments, :sha, :string, null: false
  end
end