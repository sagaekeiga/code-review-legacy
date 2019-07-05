class WelcomeController < ApplicationController
  before_action :transition_dashboard!
  layout 'welcome'

  def index
    @pulls = Pull.feed.page(params[:page])
  end

  private

  def transition_dashboard!
    return redirect_to :dashboard if user_signed_in?
  end
end
