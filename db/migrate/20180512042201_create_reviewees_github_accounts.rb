class CreateRevieweesGithubAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :reviewees_github_accounts do |t|
      t.belongs_to :reviewee, foreign_key: true
      t.string :login
      t.string :access_token
      t.bigint :owner_id
      t.string :avatar_url
      t.string :gravatar_id
      t.string :email
      t.string :url
      t.string :html_url
      t.string :user_type
      t.string :name
      t.string :nickname
      t.string :company
      t.string :location
      t.integer :public_repos
      t.integer :public_gists
      t.datetime :reviewee_created_at
      t.datetime :reviewee_updated_at
      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
