class ApplicationController < ActionController::Base
  before_action :basic_auth, if: :staging?

  private

  def basic_auth
    authenticate_or_request_with_http_basic do |username, password|
      username == ENV['BASIC_AUTH_USER'] && password == ENV['BASIC_AUTH_PASSWORD']
    end
  end

  def staging?
    ENV['WEB_DOMAIN'] == Settings.staging.domain
  end

  force_ssl if: :use_ssl?
  #
  # 本番環境かどうかを返す
  #
  def use_ssl?
    Rails.env.production?
  end
end
