class Admins::PullsController < Admins::BaseController
  def index
    @pulls = Pull.all
  end

  def show
    @pull = Pull.friendly.find(params[:id]).decorate
    @changed_files = @pull.changed_files.decorate
    @reviewers = @pull.repo.reviewers.includes(:github_account)
  end
end
