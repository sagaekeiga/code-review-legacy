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

  def self.find_for_oauth(github_account, current_reviewee)
    reviewee = find_or_initialize_by(email: github_account.email)
    if reviewee.persisted?
      reviewee.update_attributes!(last_sign_in_at: Time.zone.now)
      github_account.update_attributes!(reviewee: current_reviewee)
    else
      github_account.update_attributes!(reviewee: current_reviewee)
    end
    reviewee
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
