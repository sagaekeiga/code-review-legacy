class Reviewers::ChangedFilesController < Reviewers::BaseController
  before_action :set_pull, only: %i(index show)
  before_action :set_changed_files, only: %i(index)
  before_action :set_repo, only: %i(index show)

  def index
  end

  def show
    @pull = Pull.friendly.find(params[:pull_token])
    @changed_file = @pull.changed_files.find(params[:id])
    @res = @changed_file.content
  end

  private

  def set_pull
    @pull = Pull.friendly.find(params[:pull_token]).decorate
  end

  def set_changed_files
    @changed_files = @pull.files_changed.decorate
  end

  def set_repo
    @repo = current_reviewer.repos.friendly.find(params[:repo_id])
  end
end
