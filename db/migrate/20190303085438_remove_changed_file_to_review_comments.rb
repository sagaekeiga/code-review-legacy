class RemoveChangedFileToReviewComments < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :review_comments, :changed_files
    remove_reference :review_comments, :changed_file
  end
end