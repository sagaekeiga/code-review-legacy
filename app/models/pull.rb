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
#  fk_rails_...  (user_id => users.id)
#

class Pull < ApplicationRecord
  paginates_per 10
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  belongs_to :user
  belongs_to :repo
  has_many :pull_tags, dependent: :destroy
  has_many :tags, through: :pull_tags
  # -------------------------------------------------------------------------------
  # Validations
  # -------------------------------------------------------------------------------
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
    completed:        3000
  }
  # -------------------------------------------------------------------------------
  # Scopes
  # -------------------------------------------------------------------------------
  #
  # リクエスト可能なプルリクエストを返す
  #
  scope :opened, lambda {
    where(status: %i(connected request_reviewed)).order(remote_created_at: :desc)
  }

  scope :feed, lambda {
    request_reviewed.
      includes(:repo, :user, :pull_tags, :tags).
      order(created_at: :desc)
  }
  # -------------------------------------------------------------------------------
  # Attributes
  # -------------------------------------------------------------------------------
  attribute :status, default: statuses[:connected]
  # -------------------------------------------------------------------------------
  # ClassMethods
  # -------------------------------------------------------------------------------
  def self.fetch!(repo)
    ActiveRecord::Base.transaction do
      res_pulls = Github::Request.pulls(repo)
      language = repo.language
      res_pulls.each do |data|
        pull = repo.pulls.find_or_initialize_by(
          remote_id: data['id'],
          user: repo.user
        )
        pull.update_attributes!(
          remote_id:  data['id'],
          number:     data['number'],
          title:      data['title'],
          body:       data['body'],
          remote_created_at: data['created_at']
        )
        pull.create_or_update_tag!(language)
      end
    end
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    fail I18n.t('views.error.failed_create_pull')
  end

  def self.update_by_pull_request_event!(params)
    ActiveRecord::Base.transaction do
      user = Users::GithubAccount.find_by(owner_id: params['head']['user']['id']).user
      return true if user.nil?
      pull = find_or_initialize_by(remote_id: params['id'])
      repo = Repo.find_by(remote_id: params['head']['repo']['id'])
      language = repo.language
      pull.update_attributes!(
        title:  params['title'],
        body:   params['body'],
        number: params['number'],
        repo:   repo,
        user: user,
        remote_created_at: params['created_at']
      )
      pull.update_status!(params[:state])
      pull.create_or_update_tag!(language)
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
  def create_or_update_tag!(language)
    tag = Tag.find_by(name: language.name)
    tag = Tag.find_by(name: 'HTML') if tag.nil?
    pull_tag = pull_tags.find_or_initialize_by(tag: tag)
    pull_tag.save!
  end

  def update_status!(state)
    case state
    when 'closed', 'merged'
      completed!
    else
      connected!
    end
  end
end
