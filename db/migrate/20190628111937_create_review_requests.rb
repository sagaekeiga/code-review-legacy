class CreateReviewRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :review_requests do |t|
      t.belongs_to :user, foreign_key: true
      t.belongs_to :pull, foreign_key: true
      t.timestamps
    end
  end
end
