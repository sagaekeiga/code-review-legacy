class Reviewers::BaseController < ApplicationController
  before_action :authenticate_reviewer!
  before_action :connect_github!
  before_action :check_reviewer_status

  def connect_github!
    redirect_to reviewers_integrations_url, danger: t('reviewers.integrations.alert.danger') if current_reviewer.github_account.nil?
  end

  def check_reviewer_status
    redirect_to :reviewers_pending, notice: t('reviewers.pending.alert.danger') if current_reviewer.pending?
  end
end
