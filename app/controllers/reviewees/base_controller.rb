class Reviewees::BaseController < ApplicationController
  before_action :authenticate_reviewee!
  before_action :connect_github!

  def connect_github!
    redirect_to reviewees_integrations_url, danger: t('reviewees.pending.alert.danger') if current_reviewee.github_account.nil?
  end
end
