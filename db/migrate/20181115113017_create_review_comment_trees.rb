class CreateReviewCommentTrees < ActiveRecord::Migration[5.1]
  def change
    create_table :review_comment_trees do |t|
      t.belongs_to :comment, index: true
      t.belongs_to :reply, index: true
      t.timestamps
    end
  end
end
