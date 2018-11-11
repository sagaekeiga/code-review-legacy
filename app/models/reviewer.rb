# == Schema Information
#
# Table name: reviewers
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
#  status                 :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_reviewers_on_deleted_at            (deleted_at)
#  index_reviewers_on_email                 (email) UNIQUE
#  index_reviewers_on_reset_password_token  (reset_password_token) UNIQUE
#

class Reviewer < ApplicationRecord
  acts_as_paranoid
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  has_many :reviews
  has_many :review_comments
  has_many :pulls
  has_one :github_account, class_name: 'Reviewers::GithubAccount'

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
  attribute :status, default: statuses[:active]

  # -------------------------------------------------------------------------------
  # Validations
  # -------------------------------------------------------------------------------
  validates_acceptance_of :agreement, allow_nil: true, on: :create

  # -------------------------------------------------------------------------------
  # ClassMethods
  # -------------------------------------------------------------------------------
  def self.find_for_oauth(github_account)
    reviewer = find_or_initialize_by(email: github_account.email)
    if reviewer.persisted?
      reviewer.update_attributes(last_sign_in_at: Time.zone.now)
      github_account.save
    else
      reviewer.update_attributes(password: Devise.friendly_token.first(8))
      github_account.update_attributes(reviewer: reviewer)
    end
    reviewer
  end

  # -------------------------------------------------------------------------------
  # InstanceMethods
  # -------------------------------------------------------------------------------
  # pullのレビューコメントを返す
  def target_review_comments(pull)
    review_comments.where(changed_file: pull.changed_files).where.not(reviewer: nil)
  end
end
