class Reviewers::PullsController < Reviewers::BaseController
  before_action :set_pull, only: %i(show)
  before_action :set_repo, only: %i(index show)

  def index
    if params[:repo_id]
      @pulls =
      if params[:status] == 'closed'
        @repo.pulls.closed
      else
        @repo.pulls.open
      end
    else
      @pulls = current_reviewer.pulls.includes(:repo).decorate
    end
  end

  def show
    @reviews = current_reviewer.reviews.where(pull_id: @pull.id).order(:created_at).decorate
  end

  private

  def set_pull
    @pull = Pull.friendly.find(params[:token] || params[:pull_token]).decorate
  end

  def set_repo
    @repo = current_reviewer.repos.friendly.find(params[:repo_id]) if params[:repo_id]
  end
end
