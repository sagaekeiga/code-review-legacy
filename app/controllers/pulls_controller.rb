class PullsController < Users::BaseController
  skip_before_action :verify_authenticity_token, only: %i(update)

  def update
    @pull = current_user.pulls.find(params[:id])
    case @pull.status
    when 'connected'
      @pull.request_reviewed!
    when 'request_reviewed'
      @pull.connected!
    end
    render json: { status: @pull.status }
  end
end