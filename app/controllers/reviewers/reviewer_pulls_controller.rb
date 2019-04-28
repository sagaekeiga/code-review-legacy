class Reviewers::ReviewerPullsController < Reviewers::BaseController
  def create
    @pull = Pull.friendly.find(params[:pull_token])
    if current_reviewer.assign_to(@pull)
      redirect_to file_reviewers_pull_reviews_path(@pull), success: t('.success')
    else
      @repo = @pull.repo
      @changed_files = Pull::ChangedFileDecorator.decorate_collection @pull.changed_files
      flash[:danger] = t '.failed'
      render 'reviewers/changed_files/index'
    end
  end
end
