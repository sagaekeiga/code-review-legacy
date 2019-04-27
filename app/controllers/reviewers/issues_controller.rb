class Reviewers::IssuesController < Reviewers::BaseController
  before_action :set_pull, only: %i(index)
  before_action :set_repo, only: %i(index)

  def index
    @issues = IssueDecorator.decorate_collection @pull.issues
  end

  private

  def set_pull
    @pull = Pull.friendly.find(params[:token] || params[:pull_token]).decorate
  end

  def set_repo
    @repo = @pull.repo
  end
end
