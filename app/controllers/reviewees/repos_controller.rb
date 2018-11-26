class Reviewees::ReposController < Reviewees::BaseController
  before_action :set_repo, only: %i(update show)

  def index
    @repos = current_reviewee.viewable_repos.page(params[:page])
  end

  def show
    @pulls = @repo.pulls.order(remote_created_at: :desc)
  end

  private

  def set_repo
    @repo = Repo.friendly.find(params[:id]).decorate
  end
end
