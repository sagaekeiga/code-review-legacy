# == Schema Information
#
# Table name: reviewees
#
#  id                     :bigint(8)        not null, primary key
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
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_reviewees_on_deleted_at            (deleted_at)
#  index_reviewees_on_email                 (email) UNIQUE
#  index_reviewees_on_reset_password_token  (reset_password_token) UNIQUE
#

class Reviewee < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  has_one :github_account, class_name: 'Reviewees::GithubAccount'
  has_many :repos, as: :resource
  has_many :pulls, as: :resource
  has_many :commits, as: :resource
  has_many :reviewee_orgs
  has_many :orgs, through: :reviewee_orgs

  # -------------------------------------------------------------------------------
  # Delegations
  # -------------------------------------------------------------------------------
  delegate :avatar_url, to: :github_account
  delegate :login, to: :github_account
  delegate :nickname, to: :github_account

  # -------------------------------------------------------------------------------
  # Validations
  # -------------------------------------------------------------------------------
  validates_acceptance_of :agreement, allow_nil: true, on: :create

  def connect_to_github(auth)
    github_account = build_github_account(
      login: auth['extra']['raw_info']['login'],
      access_token: auth['credentials']['token'],
      owner_id: auth['extra']['raw_info']['id'],
      avatar_url: auth['extra']['raw_info']['avatar_url'],
      gravatar_id: auth['extra']['raw_info']['gravatar_id'],
      email: auth['info']['email'],
      url: auth['info']['url'],
      html_url: auth['extra']['raw_info']['html_url'],
      user_type: auth['extra']['raw_info']['type'],
      nickname: auth['info']['nickname'],
      name: auth['info']['name'],
      company: auth['info']['company'],
      location: auth['extra']['raw_info']['location'],
      public_gists: auth['extra']['raw_info']['public_gists'],
      public_repos: auth['extra']['raw_info']['public_repos'],
      reviewee_created_at: auth['extra']['raw_info']['created_at'],
      reviewee_updated_at: auth['extra']['raw_info']['updated_at']
    )
    github_account.save!
  end

  def viewable_repos
    repos.
      or(Repo.where(resource_type: 'Org', resource_id: orgs.pluck(:id))).
      order(updated_at: :desc)
  end

  def viewable_pulls
    pulls.
      or(Pull.where(resource_type: 'Org', resource_id: orgs.pluck(:id))).
      includes(:repo, :changed_files).
      order(updated_at: :desc)
  end

  def self.auto_complete(keyword, current_reviewee)
    includes(:github_account).
      where.not(id: current_reviewee.id).
      where('email LIKE ?', "#{keyword}%").
      select{ |reviewee| reviewee.github_account.present? }.first(10)
  end
end
