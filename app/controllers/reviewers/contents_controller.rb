class Reviewers::ContentsController < Reviewers::BaseController
  before_action :set_repo, only: %i(index)

  def index
    if params[:keyword].present?
      @result = Github::Request.search_contents keyword: params[:keyword], repo: @repo
      return
    end
    if params[:type] == 'dir' || params[:type].nil?
      @contents = Content.where(repo: @repo, path: params[:path])
    else
      @content = Content.find_by(repo: @repo, path: params[:path])
    end
  end

  private

  def set_repo
    @repo = current_reviewer.repos.friendly.find(params[:repo_id]).decorate
  end
end
