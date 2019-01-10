require 'github/request.rb'
class Reviewers::Github::IssuesController < Reviewers::BaseController
  def index
    # @TODO フェーズ2でコメントも取得する
    repo = Repo.friendly.find(params[:repo_id])
    issue_numbers = JSON.parse(params[:issue_numbers])
    titles = []
    bodies = []
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
end
