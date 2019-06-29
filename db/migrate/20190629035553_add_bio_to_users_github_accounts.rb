class AddBioToUsersGithubAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :users_github_accounts, :bio, :text
  end
end
