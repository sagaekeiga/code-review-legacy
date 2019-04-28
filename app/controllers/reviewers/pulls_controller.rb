class Reviewers::PullsController < Reviewers::BaseController
  before_action :set_pull, only: %i(show)
  before_action :set_repo, only: %i(show)

  def index
    @pulls = current_reviewer.pulls.includes(:repo).decorate
  end

  def show
    @reviews = current_reviewer.reviews.where(pull_id: @pull.id).order(:created_at)
  end

  private

  def set_pull
    @pull = Pull.friendly.find(params[:token] || params[:pull_token]).decorate
  end

  def set_repo
    @repo =
      if params[:repo_id]
        current_reviewer.repos.friendly.find(params[:repo_id]) if params[:repo_id]
      else
        @pull.repo
      end
  end
end
