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
  has_many :issues, as: :resource
  has_many :wikis, as: :resource
  has_many :commits, as: :resource
  has_many :reviewee_orgs
  has_many :orgs, through: :reviewee_orgs

  has_many :passive_memberships, class_name: 'Membership', foreign_key: 'member_id', dependent: :destroy
  has_many :owners, through: :passive_memberships, source: :owner

  has_many :active_memberships, class_name: 'Membership', foreign_key: 'owner_id', dependent: :destroy
  has_many :members, through: :active_memberships,  source: :member

  # -------------------------------------------------------------------------------
  # Delegations
  # -------------------------------------------------------------------------------
  delegate :avatar_url, to: :github_account
  delegate :login, to: :github_account

  def self.find_for_oauth(github_account)
    reviewee = find_or_initialize_by(email: github_account.email)
    if reviewee.persisted?
      reviewee.update_attributes(last_sign_in_at: Time.zone.now)
      github_account.save
    else
      reviewee.update_attributes(password: Devise.friendly_token.first(8))
      github_account.update_attributes(reviewee: reviewee)
    end
    reviewee
  end

  def viewable_repos
    owner_org_ids = owners.map{ |owner| owner.orgs.pluck(:id) }.flatten!
    repos.
      or(Repo.where(resource_type: 'Reviewee', resource_id: owners.pluck(:id))).
      or(Repo.where(resource_type: 'Org', resource_id: owner_org_ids)).
      or(Repo.where(resource_type: 'Org', resource_id: orgs.pluck(:id))).
      order(updated_at: :desc)
  end

  def viewable_pulls
    owner_org_ids = owners.map{ |owner| owner.orgs.pluck(:id) }.flatten!
    pulls.
      or(Pull.where(resource_type: 'Reviewee', resource_id: owners.pluck(:id))).
      or(Pull.where(resource_type: 'Org', resource_id: owner_org_ids)).
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
