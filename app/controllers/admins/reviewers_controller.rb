class Admins::ReviewersController < Admins::BaseController
  before_action :set_reviewer, only: %i(show edit update)
  def index
    @reviewers = Reviewer.all.includes(:github_account).order(created_at: :desc)
  end

  def show
  end

  def edit
    @reviewer = Reviewer.find(params[:id])
  end

  def update
    if params[:status]
      update_status
      return redirect_to [:admins, @reviewer]
    end
    @reviewer.skip_reconfirmation!
    if @reviewer.update(reviewer_params)
      redirect_to [:admins, @reviewer]
    else
      render :edit
    end
  end

  private

  def set_reviewer
    @reviewer = Reviewer.find(params[:id])
  end

  def reviewer_params
    params.require(:reviewer).permit(:email)
  end

  def update_status
    case params[:status]
    when 'pending'
      @reviewer.active!
      ReviewerMailer.ok(@reviewer).deliver_later
    end
  end
end
