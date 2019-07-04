class AdminsController < Admins::BaseController
  def dashboard
    @users = User.order(created_at: :desc).includes(:github_account).decorate.last(20)
  end
end
