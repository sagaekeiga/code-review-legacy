class RemoveChangedFileToReviewComments < ActiveRecord::Migration[5.2]
  def up
    remove_foreign_key :review_comments, :changed_files
    remove_reference :review_comments, :changed_file
  end

  def down
    add_foreign_key :review_comments, :changed_files
    add_refernce :review_comments, :changed_file
  end
end