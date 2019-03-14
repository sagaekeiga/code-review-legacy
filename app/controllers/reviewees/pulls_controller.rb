class Reviewees::PullsController < Reviewees::BaseController
  skip_before_action :verify_authenticity_token, only: %i(update)

  def update
    @pull = current_reviewee.find_with_org(params[:id])
    case @pull.status
    when 'connected', 'reviewed'
      @pull.request_reviewed!
    when 'request_reviewed', 'pending'
      @pull.connected!
    end
    render json: { status: @pull.status }
  end
end
