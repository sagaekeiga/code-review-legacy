class Reviewers::Github::ReviewCommentsController < Reviewers::BaseController
  def update
    review_comment = ReviewComment.find(params[:review_comment_id])
    review_comment.body = params[:body]
    success = review_comment.remote_update
    render json: { success: success, body: review_comment.body }
  end
end
