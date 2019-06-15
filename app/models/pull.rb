# == Schema Information
#
# Table name: pulls
#
#  id                :bigint(8)        not null, primary key
#  body              :string
#  number            :integer          not null
#  remote_created_at :datetime         not null
#  status            :integer          not null
#  title             :string
#  token             :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  remote_id         :integer          not null
#  repo_id           :bigint(8)
#  user_id           :bigint(8)
#
# Indexes
#
#  index_pulls_on_remote_id  (remote_id) UNIQUE
#  index_pulls_on_repo_id    (repo_id)
#  index_pulls_on_user_id    (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (repo_id => repos.id)
#

class Pull < ApplicationRecord
  include GenToken, FriendlyId
  paginates_per 20
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  belongs_to :user, polymorphic: true
  belongs_to :repo
  has_many :pull_tags, dependent: :destroy
  has_many :tags, through: :pull_tags, source: :tag
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
  # - completed        : リモートのPRをMerge/Closeした
  #
  enum status: {
    connected:        1000,
    request_reviewed: 2000,
    completed:        3000,
  }

  # -------------------------------------------------------------------------------
  # Delegations
  # -------------------------------------------------------------------------------
  delegate :full_name, to: :repo, prefix: true
  delegate :private, to: :repo, prefix: true
  delegate :token, to: :repo, prefix: true

  # -------------------------------------------------------------------------------
  # Attributes
  # -------------------------------------------------------------------------------
  attribute :status, default: statuses[:connected]

  # -------------------------------------------------------------------------------
  # Scopes
  # -------------------------------------------------------------------------------
  #
  # レビュアーがアサインされているレポジトリ and 一度もレビューされていない PRを返す
  #
  scope :feed, lambda { |reviewer|
    pulls = includes(:repo, :pull_tags, :tags).
      joins(:repo).
      request_reviewed.
      merge(reviewer.repos)
    pulls.where.not(id: Review.where(pull: pulls).pluck(:pull_id)).order(:created_at)
  }

  # scope :matched_by_tag, lambda { |reviewer|
  #   pulls = joins(:repo, :pull_tags).
  #     request_reviewed.
  #     merge(
  #       PullTag.where(
  #         tag: reviewer.tags
  #       )
  #     )
  #   pulls.where.not(id: Review.where(pull: pulls).pluck(:pull_id)).order(:created_at)
  # }

  scope :open, lambda {
    where(status: %i(request_reviewed pending reviewed)).
      includes(reviewers: :github_account).
      order(created_at: :desc)
  }

  scope :closed, lambda {
    completed.
      joins(:reviews).
      includes(reviewers: :github_account).
      order(created_at: :desc)
  }
  # -------------------------------------------------------------------------------
  # ClassMethods
  # -------------------------------------------------------------------------------
  # deletedなpullを考慮しているかどうかがupdate_by_pull_request_event!との違い
  def self.fetch!(repo)
    ActiveRecord::Base.transaction do
      res_pulls = Github::Request.pulls(repo)
      res_pulls.each do |data|
        pull = repo.pulls.with_deleted.find_or_initialize_by(
          remote_id: data['id'],
          resource_type: repo.resource_type,
          resource_id: repo.resource_id
        )
        pull.update_attributes!(
          remote_id:  data['id'],
          number:     data['number'],
          title:      data['title'],
          body:       data['body'],
          head_label: data['head']['label'],
          base_label: data['base']['label'],
          addtions:   data['addtions'],
          deletions:  data['deletions'],
          remote_created_at: data['created_at']
        )
        pull.restore if pull&.deleted?
        pull.create_or_destroy_tags
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
        addtions:   params['additions'],
        deletions:  params['deletions'],
        remote_created_at: params['created_at']
      )
      pull.update_status_by!(params[:state])
      # たまに同時作成されて重複が起こる。ここは最新の方を「物理」削除する
      dup_pulls = Pull.where(remote_id: pull.remote_id)
      dup_pulls.order(created_at: :desc).last.really_destroy! if dup_pulls.count > 1
      pull.create_or_destroy_tags
    end
    true
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    false
  end

  #
  # プルリクエストにひもづくタグの更新を行う
  #
  def create_or_destroy_tags
    keywords = title.scan(/\[(.+?)\]/)
    return if keywords.empty?
    tags = Tag.c_ins_where(name: keywords)
    return if tags.nil?
    tags.each { |tag| pull_tags.create(tag: tag) }
    pull_tags.where.not(tag: tags).delete_all
  end
  # -------------------------------------------------------------------------------
  # InstanceMethods
  # -------------------------------------------------------------------------------
  #
  # stateのパラメータに対応したstatusに更新する
  #
  def update_status_by!(state_params)
    case state_params
    when 'closed', 'merged'
      completed!
    end
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

  private

  def send_request_reviewed_mail
    self.repo.reviewers.each { |reviewer| ReviewerMailer.pull_request_notice(reviewer, self).deliver_later }
  end
end
