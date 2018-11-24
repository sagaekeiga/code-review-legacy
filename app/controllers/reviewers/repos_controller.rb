class Reviewers::ReposController < Reviewers::BaseController
  def show
    @repo = Repo.friendly.find(params[:id])
  end
end
