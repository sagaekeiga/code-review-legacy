# == Schema Information
#
# Table name: repos
#
#  id              :bigint(8)        not null, primary key
#  description     :string
#  full_name       :string
#  homepage        :string
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
  has_many :pulls, dependent: :destroy
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
            data = Github::Request.repo(repository, params)
            repo.update_attributes!(
              _merge_params(
                user,
                repository,
                params,
                data
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
    # リモートのレポジトリを更新する
    #
    def update!(params)
      github_account = Users::GithubAccount.find_by(owner_id: params[:repository][:owner][:id])
      user = github_account.user if github_account.present?
      return true if user.nil?
      repo = find_by(remote_id: params[:repository][:id])
      ActiveRecord::Base.transaction do
        repo.update_attributes!(
          description: params[:repository][:description],
          homepage: params[:repository][:homepage]
        )
      end
      true
    rescue => e
      Rails.logger.error e
      Rails.logger.error e.backtrace.join("\n")
      false
    end

    #
    # Mergee内のレポジトリを削除する
    #
    def find_and_destroy_by(remote_id:)
      Repo.find_by(remote_id: remote_id)&.destroy
    end

    private

    def _merge_params(user, repo_params, params, data)
      {
        user_id: user.id,
        name: repo_params[:name],
        full_name: repo_params[:full_name],
        private: repo_params[:private],
        installation_id: params[:installation][:id],
        description: data[:description],
        homepage: data[:homepage]
      }
    end
  end

  def language
    data = Github::Request.languages(repo: self)
    return data if data.empty?
    Language.new(
      name: data.first.first.to_s,
      lines: data.first.last.to_i
    )
  end

  def languages
    data = Github::Request.languages(repo: self)
    data.map do |lang_info|
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
  end
end
