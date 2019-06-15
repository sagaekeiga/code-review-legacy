class Webhooks::BaseController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :check_user_agent

  #
  # User-Agent が GitHub-Hookshot かどうかチェックする。
  # 不正な場合 422 エラー
  #
  def check_user_agent
    return if request.env['HTTP_USER_AGENT'].match?(%r{GitHub-Hookshot/})
    logger.warn "Invalid webhook agent error: #{request.env['HTTP_USER_AGENT']}"
    head 422
  end
end