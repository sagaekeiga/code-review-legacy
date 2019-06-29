class UsersController < Users::BaseController
  def dashboard
    @repos = current_user.repos
    @pulls = Pull.feed.page(params[:page])
    @tags = current_user.tags
  end
end
