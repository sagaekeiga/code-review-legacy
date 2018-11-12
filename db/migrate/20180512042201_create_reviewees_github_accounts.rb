class CreateRevieweesGithubAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :reviewees_github_accounts do |t|
      t.belongs_to :reviewee, foreign_key: true
      t.string :login
      t.string :access_token
      t.bigint :owner_id
      t.string :avatar_url
      t.string :email
      t.string :user_type
      t.string :name
      t.string :nickname
      t.string :company
      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
