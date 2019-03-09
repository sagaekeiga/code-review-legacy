# == Schema Information
#
# Table name: review_comments
#
#  id             :bigint(8)        not null, primary key
#  body           :text
#  deleted_at     :datetime
#  event          :integer
#  path           :string
#  position       :integer
#  read           :boolean
#  sha            :string
#  status         :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  in_reply_to_id :bigint(8)
#  remote_id      :bigint(8)
#  review_id      :bigint(8)
#  reviewer_id    :bigint(8)
#
# Indexes
#
#  index_review_comments_on_deleted_at   (deleted_at)
#  index_review_comments_on_review_id    (review_id)
#  index_review_comments_on_reviewer_id  (reviewer_id)
#
# Foreign Keys
#
#  fk_rails_...  (review_id => reviews.id)
#  fk_rails_...  (reviewer_id => reviewers.id)
#

class ReviewComment < ApplicationRecord
  acts_as_paranoid
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  belongs_to :review, optional: true
  belongs_to :reviewer, optional: true

  has_one :comment_tree, class_name: 'ReviewCommentTree', foreign_key: :reply_id, dependent: :destroy
  has_one :comment, through: :comment_tree, source: :comment

  has_many :reply_trees, class_name: 'ReviewCommentTree', foreign_key: :comment_id, dependent: :destroy
  has_many :replies, -> { order(:created_at) }, through: :reply_trees, source: :reply

  # -------------------------------------------------------------------------------
  # Enumerables
  # -------------------------------------------------------------------------------
  #
  # - pending   : コメントが作成された
  # - commented : レビューした
  #
  enum status: {
    pending:   1000,
    completed: 2000
  }
  #
  # - reviewed : reviewer(PR内)のコメント
  # - replied : reviewer(PR内)のコメントに対する返信
  #
  enum event: {
    reviewed: 1000,
    replied:  2000
  }

  # -------------------------------------------------------------------------------
  # Attributes
  # -------------------------------------------------------------------------------
  attribute :status, default: statuses[:pending]
  attribute :read, default: false

  # -------------------------------------------------------------------------------
  # Validations
  # -------------------------------------------------------------------------------
  validates :remote_id, uniqueness: true, allow_nil: true, on: %i(create)
  validates :body,      presence: true
  validates :path,      presence: true
  validates :sha,       presence: true

  # -------------------------------------------------------------------------------
  # Scopes
  # -------------------------------------------------------------------------------
  scope :unread, lambda {
    where(read: false)
  }

  # -------------------------------------------------------------------------------
  # ClassMethods
  # -------------------------------------------------------------------------------

  class << self
    def fetch!(params)

      pull = Pull.find_by(
        remote_id: params[:pull_request][:id],
        number: params[:pull_request][:number]
      )

      review = Review.where(commit_id: params[:comment][:commit_id]).last

      # PR 編集時の取得
      if params[:changes].present?
        return ReviewComment.fetch_changes!(params, pull, changed_file)
      end

      review_comment = review.review_comments.find_or_initialize_by(_comment_attributes(params))
      review_comment.update_attributes!(
        body: params[:comment][:body],
        remote_id: params[:comment][:id]
      )
    end

    # リプライレスポンスの取得
    def fetch_reply!(params)
      ActiveRecord::Base.transaction do

        pull = Pull.find_by(
          remote_id: params[:pull_request][:id],
          number: params[:pull_request][:number]
        )

        review = Review.find_by(commit_id: params[:comment][:commit_id])

        review_comment = ReviewComment.find_or_initialize_by(remote_id: params[:comment][:in_reply_to_id])
        reply = ReviewComment.find_or_initialize_by(remote_id: params[:comment][:id])

        sha = review.review_comments.last.sha

        reply_params = _reply_params(params, changed_file, review_comment)
        reply_params = reply.persisted? ? reply_params : reply_params.merge(reviewer: nil)

        reply.update_attributes!(reply_params.merge(sha: sha))



        review_comment_tree = ReviewCommentTree.new(comment: review_comment, reply: reply)
        review_comment_tree.save!
        ReviewerMailer.comment(reply).deliver_later if params[:sender][:type].eql?('User') && reply.present?
      end
      true
    rescue => e
      Rails.logger.error e
      Rails.logger.error e.backtrace.join("\n")
      false
    end

    # Edit
    def fetch_changes!(params, pull, changed_file)
      ActiveRecord::Base.transaction do
        review_comment = ReviewComment.find_by(remote_id: params[:comment][:id])
        review_comment.update_attributes!(body: params[:comment][:body])
      end
      true
    rescue => e
      Rails.logger.error e
      Rails.logger.error e.backtrace.join("\n")
      false
    end

  end

  # -------------------------------------------------------------------------------
  # InstanceMethods
  # -------------------------------------------------------------------------------

  def reviewer?(current_reviewer)
    reviewer == current_reviewer
  end

  # レビューコメント対象のコードを返す
  def target_lines
    if position > 3
      changed_file.patch&.lines[(position - 3)..position]
    elsif position > 2
      changed_file.patch&.lines[(position - 2)..position]
    elsif position > 1
      changed_file.patch&.lines[(position - 1)..position]
    else
      [] << changed_file.patch&.lines[position]
    end
  end

  def reply!
    ActiveRecord::Base.transaction do
      save!
      # 返信対象の既読処理
      if in_reply_to_id
        review_comment = ReviewComment.find_by(remote_id: in_reply_to_id)
        review_comment.update!(read: true)
      end
      comment = { body: body, in_reply_to: in_reply_to_id }
      res = Github::Request.reply(comment.to_json, changed_file.pull)

      fail res if res.is_a?(String)

      update!(remote_id: res[:id])
    end
    true
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    false
  end

  # 対象のレビューコメントを取得する
  def target_comments
    ReviewComment.where(
      review: review,
      path: path,
      position: position,
      in_reply_to_id: nil
    )
  end

  def last_reply_remote_id
    replies.present? ? replies.last.remote_id : remote_id
  end

  def has_unread_replies?
    replies.unread.present?
  end

  def count_unread_replies
    replies.unread.count
  end

  #
  # Github のコメントを更新する
  # @return [Boolean]
  #
  def remote_update
    data = Github::Request.update_review_comment(repo: review.pull.repo, review_comment: self)
    if data.is_a?(String)
      logger.error "Error: ID#{remote_id} Review Comment update failed for #{data}"
      false
    else
      update(body: data[:body])
    end
  end

  private

  class << self

    def _comment_attributes(params)
      {
        remote_id: nil,
        path: params[:comment][:path],
        position: params[:comment][:position]
      }
    end

    def _reply_params(params, review_comment)
      {
        status: :completed,
        event: :replied,
        path: params[:comment][:path],
        position: params[:comment][:position],
        body: params[:comment][:body],
        reviewer: review_comment.reviewer,
        review: review_comment.review,
        remote_id: params[:comment][:id],
        in_reply_to_id: params[:comment][:in_reply_to_id]
      }
    end
  end
end
