# frozen_string_literal: true

class Reviewers::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # 管理画面から、レビュアー画面へSSOする
  def sso
    if admin_signed_in? && params[:reviewer_id].present?
      self.resource = Reviewer.find(params[:reviewer_id])
      set_flash_message(:notice, :signed_in) if is_flashing_format?
      # bypass_sign_in(resource)
      sign_in resource, event: :authentication
      yield resource if block_given?
      redirect_to Settings.reviewers.dashboard
    else
      redirect_to root_path
    end
  end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
  #
  # ログアウト後に遷移するページ
  #
  def after_sign_out_path_for(_resource)
    Settings.top
  end
end
