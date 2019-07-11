class AddImagesToRepos < ActiveRecord::Migration[5.2]
  def change
    add_column :repos, :image, :string
  end
end
