# frozen_string_literal: true

class Reviewees::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # 管理画面から、レビュイー画面へSSOする
  def sso
    if admin_signed_in? && params[:reviewee_id].present?
      self.resource = Reviewee.find(params[:reviewee_id])
      set_flash_message(:notice, :signed_in) if is_flashing_format?
      bypass_sign_in(resource)
      yield resource if block_given?
      respond_with resource, location: Settings.reviewees.dashboard
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
end
