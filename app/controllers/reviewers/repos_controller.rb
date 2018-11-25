class Reviewers::ReposController < Reviewers::BaseController
  def show
    @repo = current_reviewer.repos.friendly.find(params[:id])
  end
end
