# == Schema Information
#
# Table name: users_github_accounts
#
#  id         :bigint(8)        not null, primary key
#  avatar_url :string
#  bio        :text
#  email      :string
#  name       :string
#  nickname   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  owner_id   :bigint(8)
#  user_id    :bigint(8)
#
# Indexes
#
#  index_users_github_accounts_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class Users::GithubAccount < ApplicationRecord
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  belongs_to :user
  # -------------------------------------------------------------------------------
  # Validations
  # -------------------------------------------------------------------------------
  validates :owner_id, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates :nickname, presence: true
  validates :avatar_url, presence: true
end
