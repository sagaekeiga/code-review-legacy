class CreateReviewersProfiles < ActiveRecord::Migration[5.2]
  def change
    create_table :reviewers_profiles do |t|
      t.belongs_to :reviewer, foreign_key: true
      t.string :company
      t.text :body
      t.timestamps
    end
  end
end
