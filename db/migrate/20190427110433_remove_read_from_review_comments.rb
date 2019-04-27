class RemoveReadFromReviewComments < ActiveRecord::Migration[5.2]
  def up
    remove_column :review_comments, :read
  end

  def down
    add_column :review_comments, :read, :boolean
  end
end
