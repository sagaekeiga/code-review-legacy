# == Schema Information
#
# Table name: reviewees
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
#  unconfirmed_email      :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_reviewees_on_confirmation_token    (confirmation_token) UNIQUE
#  index_reviewees_on_deleted_at            (deleted_at)
#  index_reviewees_on_email                 (email) UNIQUE
#  index_reviewees_on_reset_password_token  (reset_password_token) UNIQUE
#

class Reviewee < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  has_one :github_account, class_name: 'Reviewees::GithubAccount'
  has_many :repos, as: :resource
  has_many :pulls, as: :resource
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
  validates_acceptance_of :agreement, allow_nil: true, on: %i(create)

  # -------------------------------------------------------------------------------
  # InstanceMethods
  # -------------------------------------------------------------------------------
  def feed_for_repos
    repos.
      or(Repo.where(resource_type: 'Org', resource_id: orgs.pluck(:id))).
      order(updated_at: :desc)
  end

  def find_with_org(id)
    pull = Pull.where(
      id: id,
      resource_type: 'Org',
      resource_id: orgs.pluck(:id)
    ).or(pulls.where(id: id)).compact.first
    raise ActiveRecord::RecordNotFound unless pull.is_a?(Pull)
    pull
  end

  def has_repos?
    feed_for_repos.present?
  end
end
