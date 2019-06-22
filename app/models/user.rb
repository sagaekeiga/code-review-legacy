# == Schema Information
#
# Table name: users
#
#  id                     :bigint(8)        not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
         :validatable, :omniauthable, omniauth_providers: %i(github)
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  has_one :github_account, class_name: 'Users::GithubAccount'
  has_many :repos, dependent: :destroy
  has_many :pulls, dependent: :destroy
  # -------------------------------------------------------------------------------
  # Delegations
  # -------------------------------------------------------------------------------
  delegate :avatar_url, to: :github_account
  delegate :name, to: :github_account
  # -------------------------------------------------------------------------------
  # ClassMethods
  # -------------------------------------------------------------------------------
  def self.find_for_oauth(auth, signed_in_resource=nil)
    # @TODO 違うGithubAccountでログインするとGithubAccountが上書きされると思う。
    user = User.find_or_initialize_by(email: auth.info.email)

    if user.persisted?
      user.github_account.assign_attributes(
        owner_id: auth[:extra][:raw_info][:id],
        avatar_url: auth[:extra][:raw_info][:avatar_url],
        email: auth[:info][:email],
        nickname: auth[:info][:nickname],
        name: auth[:info][:name]
      )
    else
      user = User.new(
        email:    auth.info.email,
        password: Devise.friendly_token[0, 20]
      )
      user.build_github_account(
        owner_id: auth[:extra][:raw_info][:id],
        avatar_url: auth[:extra][:raw_info][:avatar_url],
        email: auth[:info][:email],
        nickname: auth[:info][:nickname],
        name: auth[:info][:name]
      )
    end
    user.save
    user
  end

  #
  # レポジトリがあるかどうかを返す
  #
  # @return [boolean]
  #
  def has_repos?
    repos.present?
  end
end
