class Admins::RevieweesController < Admins::BaseController
  def index
    @reviewees = Reviewee.all.includes(:github_account).order(created_at: :desc)
  end

  def show
    @reviewee = Reviewee.find(params[:id])
  end
end
