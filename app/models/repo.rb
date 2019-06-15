# == Schema Information
#
# Table name: repos
#
#  id              :bigint(8)        not null, primary key
#  full_name       :string
#  name            :string
#  private         :boolean
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  installation_id :bigint(8)
#  remote_id       :integer
#  user_id         :bigint(8)
#
# Indexes
#
#  index_repos_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class Repo < ApplicationRecord
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  belongs_to :user
  # -------------------------------------------------------------------------------
  # Validations
  # -------------------------------------------------------------------------------
  validates :remote_id, presence: true, uniqueness: true
  validates :name, presence: true
  validates :full_name, presence: true, uniqueness: true
  validates :private, inclusion: { in: [true, false] }
  validates :installation_id, presence: true
  # -------------------------------------------------------------------------------
  # Attributes
  # -------------------------------------------------------------------------------
  attribute :private, default: false
  # -------------------------------------------------------------------------------
  # ClassMethods
  # -------------------------------------------------------------------------------
  class << self
    #
    # リモートのレポジトリを保存する or リストアする
    #
    # @param [ActionController::Parameter] repositories_added_params addedなPOSTパラメータ
    #
    # @return [Boolean] 保存 or リストアに成功すればtrue、失敗すればfalseを返す
    #
    def fetch!(params)
      resource_type = params[:installation][:account][:type].eql?('User') ? 'Reviewee' : 'Org'
      return if resource_type == 'Org'
      github_account = Users::GithubAccount.find_by(owner_id: params[:sender][:id])
      user = github_account.user if github_account.present?
      return true if user.nil?
      repos =
        if params[:repositories_added].present?
          params[:repositories_added]
        else
          params[:repositories]
        end
      repos.each do |repository|
        begin
          ActiveRecord::Base.transaction do
            repository = ActiveSupport::HashWithIndifferentAccess.new(repository)
            repo = find_or_create_by(remote_id: repository[:id])
            repo.update_attributes!(
              _merge_params(
                user,
                repository,
                params
              )
            )
          end
          true
        rescue => e
          Rails.logger.error e
          Rails.logger.error e.backtrace.join("\n")
          false
        end
      end
    end

    #
    # Mergee内のレポジトリを削除する
    #
    def find_and_destroy_by(remote_id:)
      Repo.find_by(remote_id: remote_id)&.destroy
    end

    private

    def _merge_params(user, repo_params, params)
      {
        user_id: user.id,
        name: repo_params[:name],
        full_name: repo_params[:full_name],
        private: repo_params[:private],
        installation_id: params[:installation][:id]
      }
    end
  end
end
