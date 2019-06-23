class AddDescriptionToRepos < ActiveRecord::Migration[5.2]
  def change
    add_column :repos, :description, :string
    add_column :repos, :homepage, :string
  end
end
