class AddIndexRepos < ActiveRecord::Migration[5.1]
  def change
    add_index :repos, :resource_type
    add_index :repos, :resource_id
  end
end
