class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  add_flash_types :success, :info, :warning, :danger
  before_action :set_raven_context

  rescue_from ActiveRecord::RecordNotFound, with: :render_404
  rescue_from ActionController::RoutingError, with: :render_404
  # rescue_from Exception, with: :render_500

  def render_404
    render template: 'errors/error_404', status: 404, layout: 'application', content_type: 'text/html'
  end

  def render_500
    render template: 'errors/error_500', status: 500, layout: 'application', content_type: 'text/html'
  end

  def transition_dashboard!
    return redirect_to :reviewers_dashboard if reviewer_signed_in?
    return redirect_to :reviewees_dashboard if reviewee_signed_in?
  end

  def routing_error
    raise ActionController::RoutingError, params[:path]
  end

  private

  force_ssl if: :use_ssl?

  #
  # 本番環境かどうかを返す
  #
  def use_ssl?
    Rails.env.production?
  end

  def set_raven_context
    Raven.user_context(id: session[:current_user_id]) # or anything else in session
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end
end
