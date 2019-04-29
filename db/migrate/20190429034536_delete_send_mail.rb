class DeleteSendMail < ActiveRecord::Migration[5.2]
  def up
    drop_table :send_mails
  end

  def down
    create_table :send_mails do |t|
      t.belongs_to :reviewer, foreign_key: true
      t.string :email, null: false, default: ''
      t.timestamps
    end
  end
end
