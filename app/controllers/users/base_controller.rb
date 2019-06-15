class Users::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :connect_github!
  layout 'user'

  def connect_github!
    redirect_to users_integrations_url, danger: t('users.pending.alert.danger') if current_user.github_account.nil?
  end
end
