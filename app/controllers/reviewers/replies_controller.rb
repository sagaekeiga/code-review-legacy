require 'action_view'
require 'action_view/helpers'
include ActionView::Helpers::DateHelper

class Reviewers::RepliesController < Reviewers::BaseController
  def index
    @pull = Pull.friendly.find(params[:pull_token]).decorate
    @numbers = @pull.body.scan(/#\d+/)&.map{ |num| num.delete('#').to_i }
    @commits = @pull.commits.decorate
    @changed_files = @pull.files_changed.decorate
    @review = current_reviewer.reviews.find(params[:id] || params[:review_id])
    @reviews = @pull.reviews.where(event: %i(comment issue_comment))
  end

  def create
    review = Review.find(params[:review_id])
    review_comment = ReviewComment.find(params[:review_comment_id])
    changed_file = ChangedFile.find(params[:changed_file_id])

    review_comment = changed_file.review_comments.new(reply_params(review_comment))

    if review_comment.reply!
      render json: reply_response(review_comment)
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

  def reply_response(review_comment)
    {
      status: 'success',
      review_comment_id: review_comment.id,
      body: review_comment.body,
      avatar: review_comment.reviewer.github_account.avatar_url,
      nickname: review_comment.reviewer.github_account.nickname,
      time: time_ago_in_words(review_comment.updated_at) + '前',
      remote_id: review_comment.remote_id,
      review_id: review_comment.review_id
    }
  end
end
