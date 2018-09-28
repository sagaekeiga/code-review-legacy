class Reviewees::PullsController < Reviewees::BaseController
  skip_before_action :verify_authenticity_token, only: %i(update)

  def index
    @pulls = current_reviewee.viewable_pulls.page(params[:page])
  end

  def update
    @repo = current_reviewee.repos.find(params[:repo_id])
    @pull = current_reviewee.pulls.find(params[:id])
    case @pull.status
    when 'connected'
      @pull.request_reviewed!
    when 'request_reviewed'
      @pull.connected!
    end
    render json: { status: @pull.status }
  end
end
