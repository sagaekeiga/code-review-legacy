class AddTemplateToRepos < ActiveRecord::Migration[5.2]
  def change
    add_column :repos, :template, :boolean
  end
end
