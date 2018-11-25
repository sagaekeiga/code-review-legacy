class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  add_flash_types :success, :info, :warning, :danger
  before_action :set_raven_context

  # # 200 Success
  # def response_success(class_name, action_name)
  #   render status: 200, json: { status: 200, message: "Success #{class_name.capitalize} #{action_name.capitalize}" }
  # end

  # # 400 Bad Request
  # def response_bad_request
  #   render status: 400, json: { status: 400, message: 'Bad Request' }
  # end

  # # 401 Unauthorized
  # def response_unauthorized
  #   render status: 401, json: { status: 401, message: 'Unauthorized' }
  # end

  # # 404 Not Found
  # def response_not_found(class_name = 'page')
  #   render status: 404, json: { status: 404, message: "#{class_name.capitalize} Not Found" }
  # end

  # # 409 Conflict
  # def response_conflict(class_name)
  #   render status: 409, json: { status: 409, message: "#{class_name.capitalize} Conflict" }
  # end

  # # 500 Internal Server Error
  # def response_internal_server_error
  #   render status: 500, json: { status: 500, message: 'Internal Server Error' }
  # end

  #
  # routing errorが出たときの処理
  #
  # def routing_error
  #   raise ActionController::RoutingError, params[:path]
  # end

  # def server_error
  #   raise Exception
  # end

  def transition_dashboard!
    return redirect_to :reviewers_dashboard if reviewer_signed_in?
    return redirect_to :reviewees_dashboard if reviewee_signed_in?
  end

  # 例外ハンドル
  unless Rails.env.development?
    rescue_from Exception,                        with: :_render_500
    rescue_from ActiveRecord::RecordNotFound,     with: :_render_404
    rescue_from ActionController::RoutingError,   with: :_render_404
  end

  def routing_error
    raise ActionController::RoutingError, params[:path]
  end

  private

  def _render_404(e = nil)
    logger.info "Rendering 404 with exception: #{e.message}" if e

    if request.format.to_sym == :json
      render json: { error: '404 error' }, status: :not_found
    else
      render 'errors/404', status: :not_found
    end
  end

  def _render_500(e = nil)
    logger.error "Rendering 500 with exception: #{e.message}" if e
    Airbrake.notify(e) if e # Airbrake/Errbitを使う場合はこちら

    if request.format.to_sym == :json
      render json: { error: '500 error' }, status: :internal_server_error
    else
      render 'errors/500', status: :internal_server_error
    end
  end

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
