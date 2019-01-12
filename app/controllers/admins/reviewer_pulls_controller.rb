class Admins::ReviewerPullsController < Admins::BaseController
  def create
    @pull = Pull.friendly.find(params[:pull_id])
    @reviewer = Reviewer.find(params[:reviewer_id])
    @reviewer_pull = @pull.reviewer_pulls.new(reviewer: @reviewer)
    if @reviewer_pull.save
      redirect_to [:admins, @pull], success: "#{@reviewer.github_account&.nickname}さんをアサインしました"
    else
      @reviewers = @pull.reviewers.includes(:github_account)
      render 'admins/pull/show'
    end
  end

  def destroy
    @pull = Pull.friendly.find(params[:pull_id])
    @reviewer_pull = @pull.reviewer_pulls.find(params[:id])
    @reviewer = @reviewer_pull.reviewer
    if @reviewer_pull.destroy
      redirect_to [:admins, @pull], success: "#{@reviewer.github_account&.nickname}さんをアサインから外しました"
    else
      @reviewers = @pull.reviewers.includes(:github_account)
      render 'admins/pulls/show'
    end
  end
end
