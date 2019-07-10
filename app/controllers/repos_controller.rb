class ReposController < Users::BaseController
  def show
    @repos = current_user.repos
    @repo = current_user.repos.find(params[:id]).decorate
    @pulls = @repo.pulls.opened.decorate
    @tags =  Tag.all
  end

  def update
    repo = current_user.repos.find(params[:id])
    repo.assign_attributes(
      description: params[:description],
      homepage: params[:homepage]
    )
    render json: { success: repo.save, repo: repo }
  end
end