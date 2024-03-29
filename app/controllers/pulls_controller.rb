class PullsController < Users::BaseController
  skip_before_action :verify_authenticity_token, only: %i[update]

  def update
    @pull = current_user.pulls.find(params[:id])
    @pull.switch_ststus!

    @reviewers = current_user.not_request_users(@pull).map(&:attributes_for_request)

    render json: {
      status: @pull.status,
      reviewers: @reviewers,
      review_requests_count: @pull.review_requests.count
    }
  end
end
