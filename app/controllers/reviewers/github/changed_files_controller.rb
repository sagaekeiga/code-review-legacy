require 'github/request.rb'
class Reviewers::Github::ChangedFilesController < Reviewers::BaseController
  before_action :set_repo, only: %i(show)

  def show
    changed_file = ChangedFile.find(params[:changed_file_id])
    content_url = changed_file.contents_url.gsub!('https://api.github.com/', '')
    res = Github::Request.github_exec_fetch_content_by_cf!(@repo, content_url)
    res = ActiveSupport::HashWithIndifferentAccess.new(res)
    path = res[:path]
    content = Base64.decode64(res[:content])

    highlight_content = []

    content.each_line do |line|
      line = line.gsub(' ', '&nbsp;')
      line = line.gsub(/[<]/, '&lt;')
      line = line.gsub(/[>]/, '&gt;')
      highlight_content << line
    end
    highlight_content.map! { |e| e ? e : '' }
    render json: {
      path: path,
      content: highlight_content
    }
  end

  private

  def set_repo
    @repo = Repo.find(params[:repo_id]).decorate
  end
end
