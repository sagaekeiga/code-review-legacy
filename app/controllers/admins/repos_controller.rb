class Admins::ReposController < Admins::BaseController
  def index
    @repos = Repo.all
  end

  def show
    @repo = Repo.find(params[:id]).decorate
    @reviewers = Reviewer.all.includes(:github_account)
  end
end
