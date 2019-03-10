require 'action_view'
require 'action_view/helpers'
include ActionView::Helpers::DateHelper

class Reviewers::RepliesController < Reviewers::BaseController
  before_action :set_pull, only: %i(index)
  before_action :set_repo, only: %i(index)

  def index
    @numbers = @pull.body.scan(/#\d+/)&.map { |num| num.delete('#').to_i }
    @commits = Pull::CommitDecorator.decorate_collection @pull.commits
    @changed_files = Pull::ChangedFileDecorator.decorate_collection @pull.changed_files
    @review = current_reviewer.reviews.find(params[:id] || params[:review_id]).decorate
    @reviews = current_reviewer.reviews.where(pull_id: @pull.id).order(:created_at).decorate
  end

  def create
    review_comment = ReviewComment.find(params[:review_comment_id])
    changed_file = ChangedFile.find(params[:changed_file_id])

    review_comment = changed_file.review_comments.new(reply_params(review_comment))

    if review_comment.reply!
      render json: reply_response(review_comment: review_comment, github_account: review_comment.reviewer)
    else
      render json: { status: 'failed' }
    end
  end

  def update
    reply = ReviewComment.find(params[:id])
    reply.update(read: true)
    render json: {}
  end

  private

  def set_pull
    @pull = Pull.friendly.find(params[:pull_token]).decorate
  end

  def set_repo
    @repo = @pull.repo
  end

  def reply_params(review_comment)
    {
      event: :replied,
      position: params[:position],
      path: params[:path]&.gsub('\n', ''),
      body: params[:body],
      reviewer: review_comment.review.reviewer,
      review: review_comment.review,
      in_reply_to_id: review_comment.last_reply_remote_id,
      read: true,
      status: :completed
    }
  end

  def reply_response(review_comment:, github_account:)
    {
      status: 'success',
      review_comment_id: review_comment.id,
      body: review_comment.body,
      avatar: github_account.avatar_url,
      nickname: github_account.nickname,
      time: time_ago_in_words(review_comment.updated_at) + '前',
      remote_id: review_comment.remote_id,
      review_id: review_comment.review_id
    }
  end
end
