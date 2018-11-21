require 'github/request.rb'
class Reviewers::Github::ContentsController < Reviewers::BaseController
  before_action :set_repo, only: %i(fetch_contents)

  # 第一階層のレポジトリファイルを取得
  def fetch_contents
    res = Github::Request.github_exec_fetch_repo_contents!(@repo)
    res = ActiveSupport::HashWithIndifferentAccess.new(res)
    Rails.logger.debug res
  end

  # def show
  #   changed_file = ChangedFile.find(params[:changed_file_id])
  #   content_url = changed_file.contents_url.gsub!('https://api.github.com/', '')
  #   res = Github::Request.github_exec_fetch_content_by_cf!(@repo, content_url)
  #   res = ActiveSupport::HashWithIndifferentAccess.new(res)
  #   path = res[:path]
  #   content = Base64.decode64(res[:content])

  #   highlight_content = []

  #   content.each_line { |line| highlight_content << line.gsub(' ', '&nbsp;') }
  #   highlight_content.map! { |e| e ? e : '' }

  #   render json: {
  #     path: path,
  #     content: highlight_content
  #   }
  # end

  private

  def set_repo
    @repo = Repo.find(params[:repo_id])
  end
end
