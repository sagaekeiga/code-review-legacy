class Admins::PullsController < Admins::BaseController
  def index
    @pulls = Pull.all
  end

  def show
    @pull = Pull.friendly.find(params[:id]).decorate
    @changed_files = @pull.files_changed.decorate
    @reviewers = @pull.repo.reviewers.includes(:github_account)
  end
end
