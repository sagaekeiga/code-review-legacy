class UsersController < Users::BaseController
  def dashboard
    @repos= current_user.repos
  end
end