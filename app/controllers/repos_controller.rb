class ReposController < Users::BaseController
  def show
    @repos = current_user.repos
    @repo = current_user.repos.find(params[:id])
    @pulls = @repo.pulls.opened.decorate
    @tags =  Tag.all
  end
end
