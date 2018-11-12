# == Schema Information
#
# Table name: reviewees_github_accounts
#
#  id                  :bigint(8)        not null, primary key
#  access_token        :string
#  avatar_url          :string
#  company             :string
#  deleted_at          :datetime
#  email               :string
#  html_url            :string
#  location            :string
#  login               :string
#  name                :string
#  nickname            :string
#  public_gists        :integer
#  public_repos        :integer
#  reviewee_created_at :datetime
#  reviewee_updated_at :datetime
#  url                 :string
#  user_type           :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  gravatar_id         :string
#  owner_id            :bigint(8)
#  reviewee_id         :bigint(8)
#
# Indexes
#
#  index_reviewees_github_accounts_on_deleted_at   (deleted_at)
#  index_reviewees_github_accounts_on_reviewee_id  (reviewee_id)
#
# Foreign Keys
#
#  fk_rails_...  (reviewee_id => reviewees.id)
#

class Reviewees::GithubAccount < ApplicationRecord
  acts_as_paranoid
  # -------------------------------------------------------------------------------
  # Validations
  # -------------------------------------------------------------------------------
  validates :owner_id, presence: true, uniqueness: true
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  belongs_to :reviewee
  # -------------------------------------------------------------------------------
  # ClassMethods
  # -------------------------------------------------------------------------------
end
