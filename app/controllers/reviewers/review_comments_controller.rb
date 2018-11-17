require 'action_view'
require 'action_view/helpers'
include ActionView::Helpers::DateHelper
class Reviewers::ReviewCommentsController < Reviewers::BaseController
  before_action :set_changed_file, only: %i(create)
  before_action :set_pull, only: %i(create)
  before_action :set_review_comment, only: %i(destroy update show)

  def create
    reviewer = Reviewer.find(params[:reviewer_id])
    @changed_file = ChangedFile.find(params[:changed_file_id])

    return render json: { status: 'failed' } if @changed_file.nil? || reviewer.nil?

    review_comment = @changed_file.review_comments.new(
      event: :replied,
      position: params[:position],
      path: params[:path]&.gsub('\n', ''),
      body: params[:body],
      reviewer: reviewer
    )

    if review_comment.save
      review_comment.send_github!(params[:commit_id]) if params[:commit_id]
      render json: {
        status: 'success',
        review_comment_id: review_comment.id,
        body: params[:body],
        remote_id: review_comment.remote_id
      }
    else
      render json: { status: 'failed' }
    end
  end

  def update
    if @review_comment.update(body: params[:body])
      render json: {
        status: 'success',
        body: params[:body]
      }
    else
      render json: { status: 'failed' }
    end
  end

  def destroy
    if @review_comment.destroy
      render json: { status: 'success' }
    else
      render json: { status: 'failed' }
    end
  end

  def show
    render json: { body: @review_comment.body }
  end

  private

  def set_changed_file
    @changed_file = ChangedFile.find(params[:changed_file_id])
  end

  def set_pull
    @pull = @changed_file.pull
  end

  def set_review_comment
    @review_comment = ReviewComment.find(params[:id])
  end
end
