class ApplicationController < ActionController::Base
  private

  force_ssl if: :use_ssl?
  #
  # 本番環境かどうかを返す
  #
  def use_ssl?
    Rails.env.production?
  end
end
