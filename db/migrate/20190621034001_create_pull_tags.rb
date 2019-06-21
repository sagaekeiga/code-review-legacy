class CreatePullTags < ActiveRecord::Migration[5.2]
  def change
    create_table :pull_tags do |t|
      t.belongs_to :pull
      t.belongs_to :tag
      t.timestamps
    end
  end
end
