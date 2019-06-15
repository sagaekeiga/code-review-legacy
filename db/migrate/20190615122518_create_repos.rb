class CreateRepos < ActiveRecord::Migration[5.2]
  def change
    create_table :repos do |t|
      t.belongs_to :user, foreign_key: true
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
