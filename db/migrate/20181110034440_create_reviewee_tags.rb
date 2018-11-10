class CreateRevieweeTags < ActiveRecord::Migration[5.1]
  def change
    create_table :reviewee_tags do |t|
      t.belongs_to :reviewee
      t.belongs_to :tag
      t.timestamps
    end
  end
end
