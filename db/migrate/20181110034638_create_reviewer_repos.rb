class CreateReviewerRepos < ActiveRecord::Migration[5.1]
  def change
    create_table :reviewer_repos do |t|
      t.belongs_to :reviewer
      t.belongs_to :repo
      t.timestamps
    end
  end
end
