class DropChangedFile < ActiveRecord::Migration[5.2]
  def up
    drop_table :changed_files
  end
  def down
    create_table :changed_files do |t|
      t.belongs_to :pull, foreign_key: true
      t.belongs_to :commit, foreign_key: true
      t.string :filename
      t.integer :additions
      t.integer :deletions
      t.integer :difference
      t.string :contents_url
      t.text :patch
      t.integer :event
      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end