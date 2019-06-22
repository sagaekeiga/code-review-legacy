class UsersController < Users::BaseController
  def dashboard
    @repos = current_user.repos
    @pulls = Pull.feed.page(params[:page])
  end
end
