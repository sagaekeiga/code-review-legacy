# == Schema Information
#
# Table name: users_github_accounts
#
#  id         :bigint(8)        not null, primary key
#  avatar_url :string
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
  # Validations
  # -------------------------------------------------------------------------------
  validates :owner_id, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  belongs_to :reviewee
  # -------------------------------------------------------------------------------
  # ClassMethods
  # -------------------------------------------------------------------------------

  def self.find_for_oauth(auth, reviewee)
    github_account = find_or_initialize_by(owner_id: auth[:extra][:raw_info][:id], reviewee: user)
    github_account.assign_attributes(
      login: auth[:extra][:raw_info][:login],
      access_token: auth[:credentials][:token],
      avatar_url: auth[:extra][:raw_info][:avatar_url],
      email: auth[:info][:email],
      user_type: auth[:extra][:raw_info][:type],
      nickname: auth[:info][:nickname],
      name: auth[:info][:name],
      company: auth[:info][:company],
      user: user
    )
    github_account.save
  end
end
