class Admins::ReviewerReposController < Admins::BaseController
  def create
    repo = Repo.find(params[:repo_id])
    reviewer = Reviewer.find(params[:reviewer_id])
    reviewer_repo = repo.reviewer_repos.new(reviewer: reviewer)
    if reviewer_repo.save
      redirect_to [:admins, repo], success: "#{reviewer.github_account&.nickname}さんをアサインしました"
    else
      render :admins, :repos, :show
    end
  end
end
