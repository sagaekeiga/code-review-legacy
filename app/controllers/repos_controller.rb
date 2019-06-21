class ReposController < Users::BaseController
  def show
    @repo = current_user.repos.find(params[:id])
    @pulls = @repo.pulls.opened.decorate
    @tags =  Tag.all
  end
end
