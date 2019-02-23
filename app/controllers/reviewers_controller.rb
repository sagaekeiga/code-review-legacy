class ReviewersController < Reviewers::BaseController
  skip_before_action :connect_github!, only: %i(integrations)
  skip_before_action :check_reviewer_status, only: %i(pending integrations)

  def dashboard
    @repos = current_reviewer.repos.includes(:resource).order(updated_at: :desc).limit(10).decorate
    @pulls = Pull.feed(current_reviewer.repos).page(params[:page])
    @pending_reviews = current_reviewer.reviews.pending.includes(:pull)
  end

  def pending
    redirect_to :reviewers_dashboard unless current_reviewer.pending?
  end

  def integrations
  end

  def check_list
  end
end
