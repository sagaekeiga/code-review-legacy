require 'github/request.rb'
class Reviewers::ContentsController < Reviewers::BaseController
  before_action :set_repo, only: %i(index show)

  def index
    if params[:keyword].present?
      res = Github::Request.github_exec_search_contents_scope_repo!(@repo, params[:keyword])
      Rails.logger.debug res.to_yaml
    end
  end

  def show
    @dir_or_files = @content.children.sub(@content).decorate
  end

  private

  def set_repo
    @repo = Repo.find(params[:repo_id]).decorate
  end
end
