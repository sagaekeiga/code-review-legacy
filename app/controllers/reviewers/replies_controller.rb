require 'action_view'
require 'action_view/helpers'
include ActionView::Helpers::DateHelper

class Reviewers::RepliesController < Reviewers::BaseController
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
      status: :completed
    }
  end

  def reply_response(review_comment)
    {
      status: 'success',
      review_comment_id: review_comment.id,
      body: review_comment.body,
      img: review_comment.reviewer.github_account.avatar_url,
      name: review_comment.reviewer.github_account.nickname,
      time: time_ago_in_words(review_comment.updated_at) + '前',
      remote_id: review_comment.remote_id,
      review_id: review_comment.review_id
    }
  end
end
