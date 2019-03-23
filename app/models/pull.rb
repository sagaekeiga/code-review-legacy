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
#  index_pulls_on_deleted_at     (deleted_at)
#  index_pulls_on_remote_id      (remote_id) UNIQUE
#  index_pulls_on_repo_id        (repo_id)
#  index_pulls_on_resource_id    (resource_id)
#  index_pulls_on_resource_type  (resource_type)
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
  has_many :reviews, dependent: :destroy
  has_many :issue_comments, dependent: :destroy
  has_many :reviewer_pulls, dependent: :destroy
  has_many :reviewers, through: :reviewer_pulls, source: :reviewer
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
  delegate :resource_id, to: :repo, prefix: true
  delegate :resource_type, to: :repo, prefix: true
  delegate :full_name, to: :repo, prefix: true
  delegate :private, to: :repo, prefix: true
  delegate :token, to: :repo, prefix: true
  delegate :analysis, to: :repo, prefix: true

  # -------------------------------------------------------------------------------
  # Attributes
  # -------------------------------------------------------------------------------
  attr_accessor :head_sha, :check_run_id, :checks, :analysis
  attribute :status, default: statuses[:connected]

  # -------------------------------------------------------------------------------
  # Scopes
  # -------------------------------------------------------------------------------
  #
  # レビュアーがアサインされているレポジトリ and 一度もレビューされていない PRを返す
  #
  scope :feed, lambda { |repos|
    pulls = includes(:repo).
      joins(:repo).
      request_reviewed.
      merge(repos).
      order(:created_at)
    pull_ids_with_review = Review.where(pull: pulls).pluck(:pull_id)
    pulls.where.not(id: pull_ids_with_review)
  }

  scope :open, lambda {
    where(status: %i(request_reviewed pending reviewed)).includes(reviewers: :github_account).order(created_at: :desc)
  }

  scope :closed, lambda {
    completed.joins(:reviews).includes(reviewers: :github_account).order(created_at: :desc)
  }
  # -------------------------------------------------------------------------------
  # ClassMethods
  # -------------------------------------------------------------------------------
  # deletedなpullを考慮しているかどうかがupdate_by_pull_request_event!との違い
  def self.fetch!(repo)
    ActiveRecord::Base.transaction do
      res_pulls = Github::Request.pulls(repo)
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
        base_label: params['base']['label'],
        remote_created_at: params['created_at']
      )
      pull.update_status_by!(params[:state])
      # たまに同時作成されて重複が起こる。ここは最新の方を「物理」削除する
      dup_pulls = Pull.where(remote_id: pull.remote_id)
      dup_pulls.order(created_at: :desc).last.really_destroy! if dup_pulls.count > 1
    end
    true
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    false
  end

  # 月内に行ったレビューのプルリクエストを返す
  def self.reviewed_in_month
    completed.
      joins(:reviews).
      where(updated_at: Time.zone.today.beginning_of_month..Time.zone.today.end_of_month).
      where(reviews: { event: :comment })
  end
  # -------------------------------------------------------------------------------
  # InstanceMethods
  # -------------------------------------------------------------------------------
  def reviewer? current_reviewer
    reviewer == current_reviewer
  end

  # stateのパラメータに対応したstatusに更新する
  def update_status_by!(state_params)
    case state_params
    when 'closed', 'merged'
      completed!
    end
  end

  def resource_name
    self.resource_find.login
  end

  def resource_find
    resource_type.constantize.find(resource_id)
  end

  def request_reviewed!
    super
    send_request_reviewed_mail
  end

  #
  # プルリクエストの操作が必要かどうかを返す
  # @return [Boolean]
  #
  def need_to_operate?
    connected? || request_reviewed? || pending? || reviewed?
  end

  #
  # （レビュワーの作業が）進行中かどうかを返す
  # @return [Boolean]
  #
  def is_work_in_progress?
    request_reviewed? || pending?
  end

  #
  # installation_id を返す
  # @return [Integer]
  #
  def installation_id
    repo.installation_id
  end

  #
  # オーナ名/レポジトリ名 を返す
  # @return [String]
  #
  def full_name
    repo.full_name
  end

  #
  # Pull にひもづくコミット一覧を返す
  # @return [Array<Pull::Commit>]
  #
  def commits
    data = Github::Request.commits(pull: self)
    data.map do |commit|
      Commit.new(commit)
    end
  end

  #
  # Pull にひもづく特定のコミット1つを返す
  # @param [String] sha
  # @return [Pull::Commit]
  #
  def find_commit(sha)
    data = Github::Request.commit(pull: self, sha: sha)
    fail data if data.is_a?(String)
    Commit.new(data)
  end

  #
  # Pull にひもづく差分ファイルを返す
  # @return [Array<ChangedFile>]
  #
  def changed_files
    data = Github::Request.files pull: self
    fail data[:message] unless data.is_a?(Array)
    data.map do |file|
      ChangedFile.new(file.merge(installation_id: installation_id))
    end
  end

  #
  # Changed File を返す
  # @return [Content]
  #
  def changed_file(url:)
    data = Github::Request.ref_content(url: url, installation_id: installation_id)
    fail data if data.is_a?(String)
    Content.load(data)
  end

  #
  # Rails Best Practices を導入しているかどうかを返す
  # @return [Boolean]
  #
  def has_rbp?
    repo.has_rbp?
  end

  #
  # 静的解析を走らせる通知をPRに表示する
  # @return [Boolean]
  #
  def create_check_runs
    check_run = CheckRun.new(self.attributes.merge(status: :in_progress))
    check_run.save
  end

  #
  # 静的解析を走らせる通知を更新する
  # @return [Boolean]
  #
  def update_check_runs
    check_run = CheckRun.new(self.attributes.merge(status: :completed))
    check_run.save
  end

  private

  def send_request_reviewed_mail
    self.repo.reviewers.each { |reviewer| ReviewerMailer.pull_request_notice(reviewer, self).deliver_later }
  end
end
