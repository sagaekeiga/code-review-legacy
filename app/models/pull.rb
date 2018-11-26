# == Schema Information
#
# Table name: pulls
#
#  id                :bigint(8)        not null, primary key
#  base_label        :string
#  body              :string
#  deleted_at        :datetime
#  head_label        :string
#  number            :integer          not null
#  remote_created_at :datetime         not null
#  resource_type     :string
#  status            :integer          not null
#  title             :string
#  token             :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  remote_id         :integer          not null
#  repo_id           :bigint(8)
#  resource_id       :integer
#
# Indexes
#
#  index_pulls_on_deleted_at  (deleted_at)
#  index_pulls_on_remote_id   (remote_id) UNIQUE
#  index_pulls_on_repo_id     (repo_id)
#
# Foreign Keys
#
#  fk_rails_...  (repo_id => repos.id)
#

class Pull < ApplicationRecord
  include GenToken, FriendlyId
  acts_as_paranoid
  paginates_per 20
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  belongs_to :resource, polymorphic: true
  belongs_to :repo
  has_many :changed_files, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :commits, dependent: :destroy
  has_many :reviewer_pulls, dependent: :destroy

  # -------------------------------------------------------------------------------
  # Validations
  # -------------------------------------------------------------------------------
  validates :token, uniqueness: true
  validates :remote_id, presence: true, uniqueness: true, on: %i(create)
  validates :number, presence: true
  validates :title, presence: true
  validates :status, presence: true

  # -------------------------------------------------------------------------------
  # Enumerables
  # -------------------------------------------------------------------------------
  #
  # - connected        : APIのレスポンスから作成された状態
  # - request_reviewed : レビューをリクエストした
  # - pending          : コメントした
  # - reviewed         : レビューを完了した
  # - completed        : リモートのPRをMerge/Closeした
  #
  enum status: {
    connected:        1000,
    request_reviewed: 2000,
    pending:          3000,
    reviewed:         4000,
    completed:        5000,
  }

  # -------------------------------------------------------------------------------
  # Delegations
  # -------------------------------------------------------------------------------
  delegate :full_name, to: :repo, prefix: true
  delegate :private, to: :repo, prefix: true

  # -------------------------------------------------------------------------------
  # Attributes
  # -------------------------------------------------------------------------------
  attribute :status, default: statuses[:connected]

  # -------------------------------------------------------------------------------
  # ClassMethods
  # -------------------------------------------------------------------------------
  # deletedなpullを考慮しているかどうかがupdate_by_pull_request_event!との違い
  def self.fetch!(repo)
    ActiveRecord::Base.transaction do
      res_pulls = Github::Request.github_exec_fetch_pulls!(repo)
      res_pulls.each do |res_pull|
        pull = repo.pulls.with_deleted.find_or_initialize_by(
          remote_id: res_pull['id'],
          resource_type: repo.resource_type,
          resource_id: repo.resource_id
        )
        pull.update_attributes!(
          remote_id:  res_pull['id'],
          number:     res_pull['number'],
          title:      res_pull['title'],
          body:       res_pull['body'],
          head_label: res_pull['head']['label'],
          base_label: res_pull['base']['label'],
          remote_created_at: res_pull['created_at']
        )
        pull.restore if pull&.deleted?
        Commit.fetch!(pull)
      end
    end
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    fail I18n.t('views.error.failed_create_pull')
  end

  # pull_requestのeventで発火しリモートの変更を検知して更新する
  def self.update_by_pull_request_event!(params)
    ActiveRecord::Base.transaction do
      resource_type = params['head']['user']['type'].eql?('User') ? 'Reviewee' : 'Org'
      resource =
        if resource_type.eql?('Reviewee')
          Reviewees::GithubAccount.find_by(owner_id: params['head']['user']['id']).reviewee
        else
          Org.find_by(remote_id: params['head']['user']['id'])
        end
      return true if resource.nil?
      pull = lock.find_or_initialize_by(remote_id: params['id'])
      repo = Repo.find_by(remote_id: params['head']['repo']['id'])
      pull.update_attributes!(
        title:  params['title'],
        body:   params['body'],
        number: params['number'],
        repo:   repo,
        resource_type: resource_type,
        resource_id: resource.id,
        head_label: params['head']['label'],
        base_label: params['base']['label']
      )
      pull.update_status_by!(params[:state])
      # たまに同時作成されて重複が起こる。ここは最新の方を「物理」削除する
      dup_pulls = Pull.where(remote_id: pull.remote_id)
      dup_pulls.order(created_at: :desc).last.really_destroy! if dup_pulls.count > 1
      Commit.fetch!(pull)
    end
    true
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    false
  end

  # -------------------------------------------------------------------------------
  # InstanceMethods
  # -------------------------------------------------------------------------------
  def reviewer? current_reviewer
    reviewer == current_reviewer
  end

  # 最新のファイル差分を取得する
  def files_changed
    @changed_files = changed_files.where(commit: commits.last).compared.order(created_at: :asc)
  end

  # stateのパラメータに対応したstatusに更新する
  def update_status_by!(state_params)
    case state_params
    when 'closed', 'merged'
      completed!
    end
  end
end
