class ReviewersController < Reviewers::BaseController

  def dashboard
    @pulls = Pull.order(created_at: :desc).page(params[:page])
  end

  def my_page
    @reviewed_pulls = Pull.where(id: current_reviewer.reviews.comment.pluck(:pull_id)).page(params[:pages])
    @pending_reviews = current_reviewer.reviews.pending
  end

  def pending
    redirect_to :reviewers_dashboard unless current_reviewer.pending?
  end
end
