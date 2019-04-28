# == Schema Information
#
# Table name: reviews
#
#  id          :bigint(8)        not null, primary key
#  body        :text
#  deleted_at  :datetime
#  event       :integer
#  reason      :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  commit_id   :string
#  pull_id     :bigint(8)
#  remote_id   :bigint(8)
#  reviewer_id :bigint(8)
#
# Indexes
#
#  index_reviews_on_commit_id    (commit_id)
#  index_reviews_on_deleted_at   (deleted_at)
#  index_reviews_on_pull_id      (pull_id)
#  index_reviews_on_reviewer_id  (reviewer_id)
#
# Foreign Keys
#
#  fk_rails_...  (pull_id => pulls.id)
#  fk_rails_...  (reviewer_id => reviewers.id)
#

class Review < ApplicationRecord
  acts_as_paranoid
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  belongs_to :reviewer, optional: true
  belongs_to :pull
  has_many :review_comments, dependent: :destroy

  # -------------------------------------------------------------------------------
  # Enumerables
  # -------------------------------------------------------------------------------
  # イベント
  #
  # - pending         : 審査中
  # - comment         : コメント
  # - request_changes : 修正を要求
  # - approve         : 承認
  # - refused         : 非承認
  #
  enum event: {
    pending:         1000,
    comment:         2000,
    request_changes: 3000,
    approve:         4000,
    refused:         5000
  }

  # -------------------------------------------------------------------------------
  # Attributes
  # -------------------------------------------------------------------------------
  attribute :event, default: events[:pending]
  attribute :body, default: I18n.t('reviewers.reviews.attributes.default_html')

  # -------------------------------------------------------------------------------
  # Validations
  # -------------------------------------------------------------------------------
  validates :remote_id, uniqueness: true, allow_nil: true

  # -------------------------------------------------------------------------------
  # Delegations
  # -------------------------------------------------------------------------------
  delegate :title, to: :pull, prefix: true
  delegate :token, to: :pull, prefix: true

  # -------------------------------------------------------------------------------
  # Callbacks
  # -------------------------------------------------------------------------------
  after_commit :inform_admin, on: :create

  # -------------------------------------------------------------------------------
  # ClassMethods
  # -------------------------------------------------------------------------------
  class << self
    # レビューはidが可変なので、commit_idを識別子にする
    def update_by_commit_id!(params)
      ActiveRecord::Base.transaction do
        pull = Pull.find_by(
          remote_id: params[:pull_request][:id],
          number:    params[:pull_request][:number]
        )
        review = pull.reviews.find_by(body: params[:review][:body])
        return if review.nil?
        # レビューの内容を変えた場合は、commit_idから取得
        review.update_attributes!(
          remote_id: params[:review][:id],
          commit_id: params[:review][:commit_id]
        )
        repo = Repo.find_by(name: params[:repository][:name])
      end
      true
    rescue => e
      Rails.logger.error e
      Rails.logger.error e.backtrace.join("\n")
      false
    end

    #
    # リモートに送るレビューデータの作成・レビューコメントの更新をする
    #
    def ready_to_review!(pull, param_body)
      review = new(
        pull: pull,
        body: param_body,
        event: :pending
      )
      review.save!
      changed_files = pull.changed_files
      review_comments = review.reviewer.review_comments.pending.order(:created_at).where(sha: changed_files.map(&:sha))
      review_comments.each do |review_comment|
        review_comment.review = review
        review_comment.reviewed!
        review_comment.save!
      end
      pull.pending!
      review
    end
  end

  # -------------------------------------------------------------------------------
  # InstanceMethods
  # -------------------------------------------------------------------------------
  #
  # リモートのPRにレビューする
  # @param [String] reason (承認 or 非承認) の理由
  #
  def review!(reason:)
    update!(reason: reason)
    request_params = { body: body.insert(-1, reviewer.profile_url), event: 'COMMENT' }
    pending_review_comments = review_comments.where.not(reviewer: nil).pending

    request_params[:comments] = pending_review_comments.map do |pending_review_comment|
      {
        path: pending_review_comment.path,
        position: pending_review_comment.position.to_i,
        body: pending_review_comment.body
      }
    end

    res = Github::Request.review params: request_params.to_json, pull: pull
    fail res if res.is_a?(String)

    update!(remote_id: res[:id], commit_id: res[:commit_id])

    pending_review_comments.each(&:reviewed!).each(&:completed!)
    comment!
    pull.reviewed!

    # ReviewComment に remote_id を更新する
    data = Github::Request.review_comments review: self
    data.each.with_index do |review_comment, index|
      Rails.logger.debug "review_comment: #{review_comment}"
      pending_review_comments[index].update!(
        remote_id: review_comment[:id],
        diff_hunk: review_comment[:diff_hunk]
      )
    end

    # レビュアーに審査通過（GithubにPOST）したことを通知する
    ReviewerMailer.approve_review(self).deliver_later
  end

  #
  # レポジトリを返す
  # @return [Repo]
  #
  def repo
    pull.repo
  end

  #
  # レビュー済みのレビューコメントを返す
  # @return [ReviewComment::ActiveRecord_AssociationRelation]
  #
  def reviewed_comments
    review_comments.reviewed.order(:path)
  end

  #
  # レビューが作成さsれた時に管理者に通知を送る
  #
  def inform_admin
    AdminMailer.review(id).deliver_later
  end
end
