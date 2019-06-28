class PullsController < Users::BaseController
  skip_before_action :verify_authenticity_token, only: %i[update]

  def update
    @pull = current_user.pulls.find(params[:id])
    case @pull.status
    when 'connected'
      @pull.request_reviewed!
    when 'request_reviewed'
      @pull.connected!
    end

    @reviewers = current_user.not_request_users(@pull).map do |user|
      user.attributes.merge(
        avatar_url: user.avatar_url,
        name: user.name,
        nickname:  user.nickname
      )
    end

    render json: {
      status: @pull.status,
      reviewers: @reviewers,
      request_reviews_count: @pull.request_reviews.count
    }
  end
end
