class CreateReviewerPulls < ActiveRecord::Migration[5.1]
  def change
    create_table :reviewer_pulls do |t|
      t.belongs_to :reviewer
      t.belongs_to :pull
      t.timestamps
    end
  end
end
