class ReviewRequestsController < Users::BaseController
  def create
    users = User.where(id: params[:reviewer_ids])
    result = users.requests(params[:pull_id])
    render json: { success: result }
  end
end
