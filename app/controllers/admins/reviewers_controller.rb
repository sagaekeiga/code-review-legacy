class Admins::ReviewersController < Admins::BaseController
  before_action :set_reviewer, only: %i(show update)
  def index
    @reviewers = Reviewer.all.includes(:github_account).order(created_at: :desc)
  end

  def show
  end

  def update
    case params[:status]
    when 'pending'
      @reviewer.active!
      ReviewerMailer.ok(@reviewer).deliver_later
    end
    redirect_to [:admins, @reviewer]
  end

  private

  def set_reviewer
    @reviewer = Reviewer.find(params[:id])
  end
end
