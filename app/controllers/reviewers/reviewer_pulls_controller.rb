class Reviewers::ReviewerPullsController < Reviewers::BaseController
  # skip_before_action :set_skill!, only: %i(update)
  # skip_before_action :check_reviewer_status, only: %i(update)

  def create
    @pull = Pull.friendly.find(params[:pull_token])
    if false
      redirect_to file_reviewers_pull_reviews_path(@pull)
    else
      @repo = @pull.repo
      render 'reviewers/changed_files/index'
    end
  end
end
