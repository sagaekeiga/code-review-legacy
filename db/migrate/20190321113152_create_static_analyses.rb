class CreateStaticAnalyses < ActiveRecord::Migration[5.2]
  def change
    create_table :static_analyses do |t|
      t.string :title
      t.integer :search_name
      t.timestamps
    end
  end
end
