# == Schema Information
#
# Table name: send_mails
#
#  id          :bigint(8)        not null, primary key
#  email       :string           default(""), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  reviewer_id :bigint(8)
#
# Indexes
#
#  index_send_mails_on_reviewer_id  (reviewer_id)
#
# Foreign Keys
#
#  fk_rails_...  (reviewer_id => reviewers.id)
#

FactoryBot.define do
  factory :send_mail do
    
  end
end
