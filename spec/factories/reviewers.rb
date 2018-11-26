# == Schema Information
#
# Table name: reviewers
#
#  id                     :bigint(8)        not null, primary key
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :inet
#  deleted_at             :datetime
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :inet
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  status                 :integer
#  unconfirmed_email      :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_reviewers_on_confirmation_token    (confirmation_token) UNIQUE
#  index_reviewers_on_deleted_at            (deleted_at)
#  index_reviewers_on_email                 (email) UNIQUE
#  index_reviewers_on_reset_password_token  (reset_password_token) UNIQUE
#

FactoryBot.define do
  factory :reviewer do
    sequence(:email) { |n| "reviewer#{n}@example.com" }
    confirmed_at Time.zone.today
    password              'hogehoge'
    password_confirmation 'hogehoge'
  end
end
