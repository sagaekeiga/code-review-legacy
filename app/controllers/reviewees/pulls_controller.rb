class Reviewees::PullsController < Reviewees::BaseController
  skip_before_action :verify_authenticity_token, only: %i(update)

  def index
    @pulls = current_reviewee.viewable_pulls.page(params[:page])
  end

  def update
    @pull = Pull.find(params[:id])
    case @pull.status
    when 'connected', 'pending', 'reviewed'
      @pull.request_reviewed!
    when 'request_reviewed'
      @pull.connected!
    end
    render json: { status: @pull.status }
  end
end
