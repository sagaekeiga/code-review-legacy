class Reviewers::CommitsController < Reviewers::BaseController
  before_action :set_pull, only: %i(index show)
  before_action :set_commit, only: %i(show)
  before_action :set_commits, only: %i(index)
  before_action :set_changed_files, only: %i(show)
  before_action :set_repo, only: %i(index show)

  def index
  end

  def show
  end

  private

  def set_pull
    @pull = Pull.friendly.find(params[:pull_token]).decorate
  end

  def set_commit
    @commit = @pull.commits.find(params[:id])
  end

  def set_commits
    @commits = @pull.commits.decorate
  end

  def set_changed_files
    @changed_files = ChangedFileDecorator.decorate_collection @pull.changed_files.where(commit: @commit)
  end

  def set_repo
    @repo = current_reviewer.repos.friendly.find(params[:repo_id])
  end
end
