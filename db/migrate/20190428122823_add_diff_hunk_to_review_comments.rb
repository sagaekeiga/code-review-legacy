class AddDiffHunkToReviewComments < ActiveRecord::Migration[5.2]
  def change
    add_column :review_comments, :diff_hunk, :text
  end
end
