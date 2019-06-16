class ReposController < Users::BaseController
  def show
    @repo= current_user.repos.find(params[:id])
    @pulls = @repo.pulls.decorate
  end
end