# == Schema Information
#
# Table name: review_comments
#
#  id              :bigint(8)        not null, primary key
#  body            :text
#  deleted_at      :datetime
#  event           :integer
#  path            :string
#  position        :integer
#  status          :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  changed_file_id :bigint(8)
#  in_reply_to_id  :bigint(8)
#  remote_id       :bigint(8)
#  review_id       :bigint(8)
#  reviewer_id     :bigint(8)
#
# Indexes
#
#  index_review_comments_on_changed_file_id  (changed_file_id)
#  index_review_comments_on_deleted_at       (deleted_at)
#  index_review_comments_on_review_id        (review_id)
#  index_review_comments_on_reviewer_id      (reviewer_id)
#
# Foreign Keys
#
#  fk_rails_...  (changed_file_id => changed_files.id)
#  fk_rails_...  (review_id => reviews.id)
#  fk_rails_...  (reviewer_id => reviewers.id)
#

class ReviewComment < ApplicationRecord
  acts_as_paranoid
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  belongs_to :review, optional: true
  belongs_to :changed_file
  belongs_to :reviewer, optional: true

  has_one :comment_tree, class_name: 'ReviewCommentTree', foreign_key: :reply_id, dependent: :destroy
  has_one :comment, through: :comment_tree, source: :comment

  has_many :reply_trees, class_name: 'ReviewCommentTree', foreign_key: :comment_id, dependent: :destroy
  has_many :replies, through: :reply_trees,  source: :reply

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
  # - replid : reviewer(PR内)のコメントに対する返信
  #
  enum event: {
    reviewed: 1000,
    replied:  2000
  }

  # -------------------------------------------------------------------------------
  # Attributes
  # -------------------------------------------------------------------------------
  attribute :status, default: statuses[:pending]

  # -------------------------------------------------------------------------------
  # Validations
  # -------------------------------------------------------------------------------
  validates :remote_id, uniqueness: true, allow_nil: true, on: %i(create)
  validates :body,      presence: true
  validates :path,      presence: true

  # -------------------------------------------------------------------------------
  # Scope
  # -------------------------------------------------------------------------------
  def self.fetch!(params)

    pull = Pull.find_by(
      remote_id: params[:pull_request][:id],
      number: params[:pull_request][:number]
    )

    commit = pull.commits.find_by(
      sha: params[:comment][:commit_id]
    )

    changed_file = commit.changed_files.find_by(
      pull: pull,
      event: :compared,
      filename:  params[:comment][:path]
    )

    # 編集時の取得
    if params[:changes].present?
      return ReviewComment.fetch_changes!(params, pull, changed_file)
    end

    review_comment = ReviewComment.find_or_initialize_by(_comment_params(params, changed_file))
    review_comment.update_attributes!(
      body: params[:comment][:body],
      remote_id: params[:comment][:id]
    )
  end

  # リプライレスポンスの取得
  def self.fetch_reply!(params)
    ActiveRecord::Base.transaction do

      pull = Pull.find_by(
        remote_id: params[:pull_request][:id],
        number: params[:pull_request][:number]
      )

      commit = pull.commits.find_by(
        sha: params[:comment][:commit_id]
      )

      changed_file = commit.changed_files.find_by(
        pull: pull,
        event: :compared,
        filename:  params[:comment][:path]
      )

      review_comment = ReviewComment.find_or_initialize_by(remote_id: params[:comment][:in_reply_to_id])

      reply = ReviewComment.find_or_initialize_by(remote_id: params[:comment][:id])
      reply.update_attributes!(_reply_params(params, changed_file, review_comment))

      review_comment_tree = ReviewCommentTree.new(comment: review_comment, reply: reply)
      review_comment_tree.save!
      ReviewerMailer.comment(review_comment).deliver_later if params[:sender][:type].eql?('Bot')
    end
    true
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    false
  end

  # Edit
  def self.fetch_changes!(params, pull, changed_file)
    ActiveRecord::Base.transaction do
      review_comment = ReviewComment.find_or_initialize_by(_comment_params(params, changed_file))
      review_comment.update_attributes!(body: params[:comment][:body])
    end
    true
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    false
  end

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
      comment = { body: body, in_reply_to: in_reply_to_id }
      res = Github::Request.github_exec_review_comment!(comment.to_json, changed_file.pull)

      fail res.body unless res.code == Settings.api.created.status.code

      res = ActiveSupport::HashWithIndifferentAccess.new(JSON.load(res.body))
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

  private

  class << self

    def _comment_params(params, changed_file)
      {
        remote_id: nil,
        path: params[:comment][:path],
        position: params[:comment][:position],
        changed_file: changed_file
      }
    end

    def _reply_params(params, changed_file, review_comment)
      {
        status: :completed,
        event: :replied,
        path: params[:comment][:path],
        position: params[:comment][:position],
        changed_file: changed_file,
        body: params[:comment][:body],
        reviewer: review_comment.reviewer,
        review: review_comment.review,
        remote_id: params[:comment][:id],
        in_reply_to_id: params[:comment][:in_reply_to_id]
      }
    end
  end
end
