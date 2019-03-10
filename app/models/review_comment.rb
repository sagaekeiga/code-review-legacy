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
    #
    # Github上で作成されたレビューコメントをMergee上でも作成する
    # ただし、該当するレビューが存在しなければ作成しない
    # @param [Hash] params Webhookの中身
    #
    def fetch_reply!(params)
      review_comment = ReviewComment.find_by(remote_id: params[:comment][:in_reply_to_id])
      reply = ReviewComment.find_by(remote_id: params[:comment][:id])
      # @MEMO Githubからの返信かどうかを返す
      #       Mergee側で作成したコメントのwebhookでないかどうか
      return if review_comment.nil? || reply.present?

      ActiveRecord::Base.transaction do
        reply = ReviewComment.new(_reply_params(params, review_comment))
        reply.save!
        review_comment_tree = ReviewCommentTree.new(comment: review_comment, reply: reply)
        review_comment_tree.save!
        ReviewerMailer.comment(reply).deliver_later
      end
      true
    rescue => e
      Rails.logger.error e
      Rails.logger.error e.backtrace.join("\n")
      false
    end

    #
    # Github上でレビューコメントの更新内容を Mergee に反映する
    # @param [Hash] params Webhookの中身
    #
    def fetch_changes!(params)
      review_comment = ReviewComment.find_by(remote_id: params[:comment][:id])
      return if review_comment.nil?
      ActiveRecord::Base.transaction do
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
        review_comment_tree = ReviewCommentTree.new(comment: review_comment, reply: self)
        review_comment_tree.save!
      end
      comment = { body: body, in_reply_to: in_reply_to_id }
      res = Github::Request.reply(comment.to_json, pull)

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
  # PR を返す
  # @return [Pull]
  #
  def pull
    review.pull
  end

  #
  # PR を返す
  # コミットIDを返す
  # @reuturn [Integer]
  #
  def commit_id
    review.commit_id
  end

  #
  # コメントした差分を返す
  # @return [Pull::ChangedFile]
  #
  def changed_file
    pull.changed_files.detect { |changed_file| changed_file.sha == sha }
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

    def _reply_params(params, review_comment)
      {
        remote_id: params[:comment][:id],
        body: params[:comment][:body],
        event: :replied,
        path: params[:comment][:path],
        position: params[:comment][:position],
        sha: review_comment.sha,
        in_reply_to_id: params[:comment][:in_reply_to_id],
        status: :completed,
        review_id: review_comment.review.id
      }
    end

  end
end
