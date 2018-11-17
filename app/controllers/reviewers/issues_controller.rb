class Reviewers::IssuesController < Reviewers::BaseController
  before_action :set_repo, only: %i(index show)
  before_action :set_issue, only: %i(show)
  def index
    @issues = @repo.issues.showing
  end

  def show
  end

  def remote
    # @TODO フェーズ2でコメントも取得する
    repo = Repo.find(params[:repo_id])
    issue_numbers = JSON.parse(params[:issue_numbers])
    titles, bodies = [], []
    issue_numbers.each do |issue_number|
      res = Github::Request.github_exec_fetch_issue_by_number(repo, issue_number)
      res = ActiveSupport::HashWithIndifferentAccess.new(res)
      titles << res[:title]
      bodies << res[:body]
    end
    render json: {
      titles: titles,
      bodies: bodies,
      issue_numbers: issue_numbers
    }
  end

  private

  def set_repo
    @repo = Repo.find(params[:repo_id])
  end

   def set_issue
     @issue = @repo.issues.find(params[:id])
   end
end
