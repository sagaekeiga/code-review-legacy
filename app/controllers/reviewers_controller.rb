class ReviewersController < Reviewers::BaseController
  skip_before_action :connect_github!, only: %i(integrations)
  skip_before_action :set_skill!, only: %i(skill integrations)
  skip_before_action :check_reviewer_status, only: %i(skill pending integrations)

  def dashboard
    @repos = current_reviewer.repos.includes(:resource).order(updated_at: :desc).limit(10).decorate
    @pulls = Pull.matched_by_tag(current_reviewer).page(params[:page])
    @pending_reviews = current_reviewer.reviews.pending.includes(:pull)
  end

  def show
    @reviewer = Reviewer.find(params[:id])
  end

  def pending
    redirect_to :reviewers_dashboard unless current_reviewer.pending?
  end

  def skill
    @reviewer = current_reviewer
    @reviewer_tags = current_reviewer.reviewer_tags.includes(:tag)
  end

  def profile
  end

  def integrations
  end

  def check_list
  end
end
