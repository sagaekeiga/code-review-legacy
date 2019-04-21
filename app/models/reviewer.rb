# == Schema Information
#
# Table name: reviewers
#
#  id                     :bigint(8)        not null, primary key
#  address                :string
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
#  name                   :string
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

class Reviewer < ApplicationRecord
  acts_as_paranoid
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  has_many :reviews
  has_many :review_comments
  has_many :reviewer_repos
  has_many :repos, through: :reviewer_repos, source: :repo
  has_many :reviewer_pulls
  has_many :pulls, through: :reviewer_pulls, source: :pull
  has_many :send_mails
  has_one :github_account, class_name: 'Reviewers::GithubAccount'
  has_one :profile, class_name: 'Reviewers::Profile'
  has_many :reviewer_tags, dependent: :destroy
  has_many :tags, through: :reviewer_tags, source: :tag
  # -------------------------------------------------------------------------------
  # Delegations
  # -------------------------------------------------------------------------------
  delegate :avatar_url, to: :github_account
  delegate :nickname, to: :github_account

  # -------------------------------------------------------------------------------
  # Enumerables
  # -------------------------------------------------------------------------------
  # ステータス
  #
  # - pending         : 登録済み（承認待ち）
  # - active          : 活動中
  # - rejected        : 非承認済み
  # - quit            : 退会済み
  #
  enum status: {
    pending:  1000,
    active:   2000,
    rejected: 3000,
    quit:     4000
  }

  # -------------------------------------------------------------------------------
  # Attributes
  # -------------------------------------------------------------------------------
  attribute :status, default: statuses[:pending]

  # -------------------------------------------------------------------------------
  # Validations
  # -------------------------------------------------------------------------------
  validates_acceptance_of :agreement, allow_nil: true, on: :create
  validates :name, presence: true
  validates :address, presence: true

  # -------------------------------------------------------------------------------
  # InstanceMethods
  # -------------------------------------------------------------------------------
  # レポジトリにアサインされているかどうかを返す
  def assigned?(resource)
    case resource
    when Repo then reviewer_repos.exists?(repo: resource)
    when Pull then reviewer_pulls.exists?(pull: resource)
    end
  end

  def assign_to!(pull)
    ActiveRecord::Base.transaction do
      return true if assigned?(pull)
      reviewer_pull = reviewer_pulls.new(pull: pull)
      reviewer_pull.save!
    end
    true
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    false
  end

  def monthly_reward
    changed_files_count = 0
    return changed_files_count unless pulls.completed.present?
    pulls = self.pulls.reviewed_in_month
    pulls.each { |pull| changed_files_count += pull.changed_files.size }
    changed_files_count * Settings.rewards.price
  end

  #
  # プロフィールを書いたかどうかを返す
  # @return [Boolean]
  #
  def wrote_profile?
    profile && profile.persisted?
  end

  #
  # レビュアーのプロフィールURLを返す
  #
  # @return [String]
  #
  def profile_url
    "\n\n\n\n<a href='#{Settings.reviewers.profile}#{id}'>レビュアーのプロフィールを見る</a>"
  end

  def create_or_destroy_tags(params)
    return false if params[:tags].nil?
    tag_ids = params[:tags].map do |params_tag|
      tag = Tag.c_ins_where(name: params_tag[:name]).first
      reviewer_tag = reviewer_tags.find_or_initialize_by(tag: tag)
      reviewer_tag.assign_attributes(year: params_tag[:year].to_i)
      Rails.logger.debug "reviewer_tag: #{reviewer_tag.attributes}"
      reviewer_tag.save
      tag.id
    end
    reviewer_tags.where.not(tag_id: tag_ids).delete_all
    true
  end
end
