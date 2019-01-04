class AddAddressToReviewers < ActiveRecord::Migration[5.1]
  def change
    add_column :reviewers, :address, :string
    add_column :reviewers, :name, :string
  end
end
