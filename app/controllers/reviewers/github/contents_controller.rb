require 'github/request.rb'
class Reviewers::Github::ContentsController < Reviewers::BaseController
  before_action :set_repo, only: %i(get_contents)

  # 第一階層のレポジトリファイルを取得
  def get_contents
    Rails.logger.debug params[:file_type]
    # @MEMO 単一も複数形の変数
    res = Github::Request.github_exec_fetch_repo_contents!(@repo, params[:path])
    res =
      case params[:file_type]
      when 'dir'
        names, paths, types = [], [], []
        res.each do |content|
          content = ActiveSupport::HashWithIndifferentAccess.new(content)
          names << content[:name]
          paths << content[:path]
          types << content[:type]
        end
        dir_response(names, paths, types)
      when 'file'
        content = ActiveSupport::HashWithIndifferentAccess.new(res)
        file_response(content)
      else
        names, paths, types = [], [], []
        res.each do |content|
          content = ActiveSupport::HashWithIndifferentAccess.new(content)
          names << content[:name]
          paths << content[:path]
          types << content[:type]
        end
        dir_response(names, paths, types)
      end
    render json: res
  end

  private

  def set_repo
    @repo = Repo.find(params[:repo_id])
  end

  def dir_response(names, paths, types)
    {
      names: names.reverse,
      paths: paths.reverse,
      types: types.reverse
    }
  end

  def file_response(res)
    highlight_content = []
    content = Base64.decode64(res[:content]).force_encoding('UTF-8')

    content.each_line { |line| highlight_content << line.gsub(' ', '&nbsp;') }
    highlight_content.map! { |e| e ? e : '' }
    {
      name: res[:name],
      path: res[:path],
      type: res[:type],
      content: highlight_content.reverse
    }
  end
end
