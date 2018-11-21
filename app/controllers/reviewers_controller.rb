class ReviewersController < Reviewers::BaseController
  skip_before_action :connect_github!, only: %i(integrations)
  skip_before_action :check_reviewer_status, only: %i(pending integrations)

  def dashboard
    @repo = current_reviewer.repos
    @pulls = current_reviewer.repos.feed_for_pulls.page(params[:page])
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
