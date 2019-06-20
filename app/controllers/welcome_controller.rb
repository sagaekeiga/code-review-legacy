class WelcomeController < ApplicationController
  before_action :transition_dashboard!

  def index
  end

  private

  def transition_dashboard!
    return redirect_to :users_dashboard if user_signed_in?
  end
end
