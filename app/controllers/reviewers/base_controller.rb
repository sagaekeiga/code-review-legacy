class Reviewers::BaseController < ApplicationController
  before_action :authenticate_reviewer!
  before_action :connect_github!
  before_action :set_skill!
  before_action :check_reviewer_status
  layout 'reviewer'

  def connect_github!
    redirect_to reviewers_integrations_url, danger: t('reviewers.integrations.alert.danger') if current_reviewer.github_account.nil?
  end

  def check_reviewer_status
    redirect_to :reviewers_pending, notice: t('reviewers.pending.alert.danger') if current_reviewer.pending?
  end

  def set_skill!
    redirect_to reviewers_skill_url, danger: t('reviewers.skillings.edit.alert') if current_reviewer.tags.none?
  end
end
