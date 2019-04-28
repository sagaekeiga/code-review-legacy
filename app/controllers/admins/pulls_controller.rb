class Admins::PullsController < Admins::BaseController
  def index
    @pulls = Pull.all
  end

  def show
    @pull = Pull.friendly.find(params[:id]).decorate
    @changed_files = Pull::ChangedFileDecorator.decorate_collection @pull.changed_files
    @reviewers = @pull.repo.reviewers.includes(:github_account)
  end
end
