class Reviewees::BaseController < ApplicationController
  before_action :authenticate_reviewee!
  before_action :connect_github!

  def connect_github!
    redirect_to reviewees_settings_integrations_url, danger: t('reviewees.settings.integrations.alert.danger') if current_reviewee.github_account.nil?
  end

  def check_reviweee_identity
    @other = true unless @repo.reviewee?(current_reviewee) || @repo.reviewee_org?(current_reviewee) || @repo.membership?(current_reviewee)
  end
end
