class FeedController < ApplicationController
  def index
    @pulls =
      if params[:tag_name].present?
        @tag = Tag.find_by(name: params[:tag_name])
        @tag.pulls.request_reviewed.order(updated_at: :desc).page(params[:page]).decorate
      else
        Pull.request_reviewed.order(updated_at: :desc).page(params[:page]).decorate
      end
    respond_to do |format|
      format.rss { render layout: false }
    end
  end
end
