class Reviewers::RepliesController < Reviewers::BaseController
  before_action :set_changed_file, only: %i(create)
  before_action :set_pull, only: %i(create)
  before_action :set_review_comment, only: %i(destroy update show)
  def create
    reviewer = Reviewer.find(params[:reviewer_id])
    review = Review.find(params[:review_id])
    review_comment = ReviewComment.find(params[:review_comment_id])
    @changed_file = ChangedFile.find(params[:changed_file_id])

    return render json: { status: 'failed' } if @changed_file.nil? || reviewer.nil?

    review_comment = @changed_file.review_comments.new(
      event: :replied,
      position: params[:position],
      path: params[:path]&.gsub('\n', ''),
      body: params[:body],
      reviewer: reviewer,
      review: review,
      in_reply_to_id: review_comment.last_reply_remote_id,
      status: :completed
    )

    if review_comment.save!
      review_comment.send_github!(params[:commit_id]) if params[:commit_id]
      render json: {
        status: 'success',
        review_comment_id: review_comment.id,
        body: params[:body],
        img: reviewer.github_account.avatar_url,
        name: reviewer.github_account.nickname,
        time: time_ago_in_words(review_comment.updated_at) + '前',
        remote_id: review_comment.remote_id,
        review_id: review_comment.review_id
      }
    else
      render json: { status: 'failed' }
    end
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
