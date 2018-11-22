class ReviewersController < Reviewers::BaseController
  skip_before_action :connect_github!, only: %i(integrations)
  skip_before_action :check_reviewer_status, only: %i(pending integrations)

  def dashboard
    @repo = current_reviewer.repos.includes(:resource).order(updated_at: :desc).limit(10)
    @pulls = Pull.joins(:repo).where(status: :request_reviewed).merge(Repo.where(id: current_reviewer.repos)).order(updated_at: :desc).page(params[:page])
    @pending_reviews = current_reviewer.reviews.where(event: :pending).includes(:pull)
  end

  def my_page
    @reviewed_pulls = Pull.where(id: current_reviewer.reviews.comment.pluck(:pull_id)).page(params[:pages])
    @pending_reviews = current_reviewer.reviews.pending
  end

  def pending
    redirect_to :reviewers_dashboard unless current_reviewer.pending?
  end

  def integrations
  end
end
