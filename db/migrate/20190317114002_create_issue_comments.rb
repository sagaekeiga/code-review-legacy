class CreateIssueComments < ActiveRecord::Migration[5.2]
  def change
    create_table :issue_comments do |t|
      t.belongs_to :pull, foreign_key: true
      t.timestamps
    end
  end
end
