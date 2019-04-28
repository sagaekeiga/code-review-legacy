class AddAdditionToPulls < ActiveRecord::Migration[5.2]
  def change
    add_column :pulls, :addtions, :integer
    add_column :pulls, :deletions, :integer
  end
end
