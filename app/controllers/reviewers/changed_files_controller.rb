class Reviewers::ChangedFilesController < Reviewers::BaseController
  before_action :set_pull, only: %i(index show)
  before_action :set_changed_files, only: %i(index)
  before_action :set_repo, only: %i(index show)

  def index
  end

  def show
    @pull = Pull.friendly.find(params[:pull_token])
    @content = @pull.changed_file(url: params[:contents_url])
  end

  private

  def set_pull
    @pull = Pull.friendly.find(params[:pull_token]).decorate
  end

  def set_changed_files
    @changed_files = Pull::ChangedFileDecorator.decorate_collection @pull.changed_files
  end

  def set_repo
    @repo = current_reviewer.repos.friendly.find(params[:repo_id])
  end
end
