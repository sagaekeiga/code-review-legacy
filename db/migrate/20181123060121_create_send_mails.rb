class CreateSendMails < ActiveRecord::Migration[5.1]
  def change
    create_table :send_mails do |t|
      t.belongs_to :reviewer, foreign_key: true
      t.string :email, null: false, default: ""

      t.timestamps
    end
  end
end
