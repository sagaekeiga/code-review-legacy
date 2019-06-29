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
  has_many :review_requests, dependent: :destroy
  # -------------------------------------------------------------------------------
  # Delegations
  # -------------------------------------------------------------------------------
  delegate :avatar_url, to: :github_account
  delegate :name, to: :github_account
  delegate :nickname, to: :github_account
  delegate :bio, to: :github_account
  # -------------------------------------------------------------------------------
  # ClassMethods
  # -------------------------------------------------------------------------------
  class << self
    def find_for_oauth(auth, signed_in_resource=nil)
      user = User.find_or_initialize_by(email: auth.info.email)

      if user.persisted?
        user.github_account.assign_attributes(_merge_params(auth))
      else
        user.assign_attributes(password: Devise.friendly_token[0, 20])
        user.build_github_account(_merge_params(auth))
      end
      user.save
      user
    end

    def requests(pull_id)
      ActiveRecord::Base.transaction do
        all.each do |user|
          review_request = user.review_requests.new(pull_id: pull_id)
          review_request.save!
        end
      end
      true
    rescue => e
      Rails.logger.error e
      Rails.logger.error e.backtrace.join("\n")
      false
    end

    private

    def _merge_params(auth)
      {
        owner_id: auth[:extra][:raw_info][:id],
        avatar_url: auth[:extra][:raw_info][:avatar_url],
        bio: auth[:extra][:raw_info][:bio],
        email: auth[:info][:email],
        nickname: auth[:info][:nickname],
        name: auth[:info][:name]
      }
    end
  end

  def not_request_users(pull)
    review_request = ReviewRequest.where(pull: pull)
    User.includes(:github_account).where.not(id: review_requests.pluck(:user_id).push(id))
  end
end
