class WelcomeController < ApplicationController
  before_action :transition_dashboard!
  def index
    @pulls = Pull.request_reviewed.
      includes(:repo).
      order(created_at: :desc).
      select{ |pull| pull.repo.private == false }.
      first(10)
  end

  def term
  end
end
