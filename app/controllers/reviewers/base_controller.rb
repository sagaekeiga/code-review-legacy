class Reviewers::BaseController < ApplicationController
  before_action :authenticate_reviewer!
  before_action :connect_github!

  def connect_github!
    redirect_to reviewers_integrations_url, danger: t('reviewers.integrations.alert.danger') if current_reviewer.github_account.nil?
  end
end
