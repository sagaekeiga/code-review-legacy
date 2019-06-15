# == Schema Information
#
# Table name: repos
#
#  id              :bigint(8)        not null, primary key
#  full_name       :string
#  name            :string
#  private         :boolean
#  token           :string           not null
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

class Repo < ApplicationRecord
  include GenToken, FriendlyId
  paginates_per 10
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  belongs_to :user
  has_many :pulls, dependent: :destroy
  has_many :reviewer_repos, dependent: :destroy
  has_many :reviewers, through: :reviewer_repos, source: :reviewer
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
      resource_type = params[:installation][:account][:type].eql?('User') ? 'User' : 'Org'
      resource = _set_resource_for_repo(params, resource_type)
      return true if resource.nil?
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
            repo = with_deleted.find_or_create_by(remote_id: repository[:id])
            repo.restore if repo&.deleted?
            repo.update_attributes!(
              _merge_params(
                resource_type,
                resource,
                repository,
                params
              )
            )
            Pull.fetch!(repo)
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

    def _set_resource_for_repo(params, resource_type)
      github_account = Users::GithubAccount.find_by(owner_id: params[:sender][:id])
      user = github_account.user if github_account.present?
      resource =
        if resource_type.eql?('User')
          user
        else
          org = Org.find_or_initialize_by(remote_id: params[:installation][:account][:id])
          org.update_attributes!(_merge_org_params(params[:installation][:account]))
          return org if user.nil?
          user_org = user.user_orgs.find_or_initialize_by(org: org)
          user_org.save!
          org
        end
    end

    def _merge_org_params(params)
      {
        avatar_url: params[:avatar_url],
        login: params[:login]
      }
    end

    def _merge_params(resource_type, resource, repo_params, params)
      {
        resource_type: resource_type,
        resource_id: resource.id,
        name: repo_params[:name],
        full_name: repo_params[:full_name],
        private: repo_params[:private],
        installation_id: params[:installation][:id]
      }
    end
  end

  def user?(current_user)
    resource_type.eql?('User') && resource_id.eql?(current_user.id)
  end

  def user_org?(current_user)
    resource_type.eql?('Org') && current_user.orgs.exists?(id: resource_id)
  end

  def readme
    Github::Request.readme repo: self
  end

  def languages
    data = Github::Request.languages(repo: self)
    data.map.with_index do |lang_info, index|
      Language.new(
        name: lang_info.first.to_s,
        lines: lang_info.last.to_i
      )
    end
  end

  class Language
    include ActiveModel::Model
    include ActiveModel::Attributes
    include Draper::Decoratable

    attr_accessor :name, :lines

    #
    # @param [Hash] data
    #
    def initialize(data = {})
      self.name = data[:name]
      self.lines = data[:lines]
    end

    def rate(sum)
      (lines.to_f / sum.to_f) * 100.0
    end
  end
end
