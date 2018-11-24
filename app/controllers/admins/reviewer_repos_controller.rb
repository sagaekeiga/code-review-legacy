class Admins::ReviewerReposController < Admins::BaseController
  def create
    @repo = Repo.friendly.find(params[:repo_id])
    @reviewer = Reviewer.find(params[:reviewer_id])
    @reviewer_repo = @repo.reviewer_repos.new(reviewer: @reviewer)
    if @reviewer_repo.save
      redirect_to [:admins, @repo], success: "#{@reviewer.github_account&.nickname}さんをアサインしました"
    else
      @reviewers = Reviewer.all.includes(:github_account)
      render 'admins/repos/show'
    end
  end

  def destroy
    @reviewer_repo = ReviewerRepo.find(params[:id])
    @repo = @reviewer_repo.repo
    @reviewer = @reviewer_repo.reviewer
    if @reviewer_repo.destroy
      redirect_to [:admins, @repo], success: "#{@reviewer.github_account&.nickname}さんをアサインから外しました"
    else
      @reviewers = Reviewer.all.includes(:github_account)
      render 'admins/repos/show'
    end
  end
end
