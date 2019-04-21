class CreateReviewerTags < ActiveRecord::Migration[5.2]
  def change
    create_table :reviewer_tags do |t|
      t.belongs_to :reviewer
      t.belongs_to :tag
      t.integer :year
      t.timestamps
    end
  end
end
