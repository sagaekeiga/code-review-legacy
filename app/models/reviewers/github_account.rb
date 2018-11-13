# == Schema Information
#
# Table name: reviewers_github_accounts
#
#  id          :bigint(8)        not null, primary key
#  avatar_url  :string
#  company     :string
#  deleted_at  :datetime
#  email       :string
#  login       :string
#  name        :string
#  nickname    :string
#  user_type   :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  owner_id    :bigint(8)
#  reviewer_id :bigint(8)
#
# Indexes
#
#  index_reviewers_github_accounts_on_deleted_at   (deleted_at)
#  index_reviewers_github_accounts_on_reviewer_id  (reviewer_id)
#
# Foreign Keys
#
#  fk_rails_...  (reviewer_id => reviewers.id)
#

class Reviewers::GithubAccount < ApplicationRecord
  acts_as_paranoid
  # -------------------------------------------------------------------------------
  # Validations
  # -------------------------------------------------------------------------------
  validates :owner_id, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  belongs_to :reviewer
  # -------------------------------------------------------------------------------
  # ClassMethods
  # -------------------------------------------------------------------------------
  def self.find_for_oauth(auth)
    github_account = find_or_initialize_by(owner_id: auth['extra']['raw_info']['id'])
    github_account.assign_attributes(
      login: auth['extra']['raw_info']['login'],
      avatar_url: auth['extra']['raw_info']['avatar_url'],
      email: auth['info']['email'],
      user_type: auth['extra']['raw_info']['type'],
      nickname: auth['info']['nickname'],
      name: auth['info']['name'],
      company: auth['info']['company']
    )
    github_account
  end
end
