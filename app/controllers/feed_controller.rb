class FeedController < ApplicationController
  def index
    @pulls = Pull.request_reviewed.order(created_at: :desc).page(params[:page]).decorate
    respond_to do |format|
      format.rss { render layout: false }
    end
  end
end