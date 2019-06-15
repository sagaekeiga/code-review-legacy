class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers: %i(github)
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  has_one :github_account, class_name: 'Users::GithubAccount'
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
end
