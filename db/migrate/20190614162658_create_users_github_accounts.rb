class CreateUsersGithubAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :users_github_accounts do |t|
      t.belongs_to :user, foreign_key: true
      t.string :name
      t.bigint :owner_id
      t.string :avatar_url
      t.string :email
      t.string :nickname
      t.timestamps
    end
  end
end
