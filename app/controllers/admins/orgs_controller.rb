class Admins::OrgsController < Admins::BaseController
  def index
    @orgs = Org.all.order(created_at: :desc)
  end

  def show
    @org = Org.find(params[:id])
    @orgs_reviewees = @org.reviewees.includes(:github_account)
    @reviewees = Reviewee.where.not(id: @orgs_reviewees.pluck(:id)).includes(:github_account)
  end
end
