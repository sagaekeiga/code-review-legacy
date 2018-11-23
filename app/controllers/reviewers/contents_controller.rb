class Reviewers::ContentsController < Reviewers::BaseController
  before_action :set_repo, only: %i(index show)

  def show
    @dir_or_files = @content.children.sub(@content).decorate
  end

  private

  def set_repo
    @repo = Repo.find(params[:repo_id]).decorate
  end
end
