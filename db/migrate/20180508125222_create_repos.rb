class CreateRepos < ActiveRecord::Migration[5.1]
  def change
    create_table :repos do |t|
      t.belongs_to :user
      t.integer :remote_id
      t.string :name
      t.string :full_name
      t.boolean :private
      t.bigint :installation_id
      t.string :token, null: false
      t.timestamps
    end
  end
end
