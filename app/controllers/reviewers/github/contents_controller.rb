require 'github/request.rb'
class Reviewers::Github::ContentsController < Reviewers::BaseController
  before_action :set_repo, only: %i(get_contents)

  # GET レポジトリファイル・ディレクトリを取得
  def get_contents
    res = Github::Request.github_exec_fetch_repo_contents!(@repo, params[:path])
    res = format_response(res)
    render json: res
  end

  private

  def set_repo
    @repo = Repo.friendly.find(params[:repo_id])
  end

  # GitHub APIのレスポンスを表示用（ファイルまたはディレクトリ）に加工して返す
  def format_response(res)
    breadcrumbs, breadcrumb_paths = new_breadcrumbs
    if params[:file_type].eql?('file')
      content = ActiveSupport::HashWithIndifferentAccess.new(res)
      file_response(content, breadcrumbs, breadcrumb_paths)
    else
      names, paths, types = [], [], []
      res.each do |content|
        content = ActiveSupport::HashWithIndifferentAccess.new(content)
        names << content[:name]
        paths << content[:path]
        types << content[:type]
      end
      dir_response(names, paths, types, breadcrumbs, breadcrumb_paths)
    end
  end

  # パンくずリスト作成用の配列を返す
  def new_breadcrumbs
    return [], [] unless params[:path].present?
    path = 
      if params[:file_type].eql?('file')
        params[:path].gsub(%r"#{params[:name]}$",'')
      else
        params[:path]
      end
    breadcrumbs = path.split('/')
    breadcrumb_paths = []
    if breadcrumbs.size > 1 # 1 #=> 第二階層かどうか
      breadcrumbs.each.with_index(1) do |breadcrumb, index|
        # 対象ファイル・ディレクトリ（breadcrumb）までのパスを取得する
        #   ex. ['/app', '/app/views', '/app/views/reviewers']
        href = ''
        index = index.to_i
        index.times do |time|
          time = time.to_i if (index- 1).eql?(time.to_i)
          href += '/' + breadcrumbs[time]
        end
        href = '/' + breadcrumbs[0] if index.eql?(0)
        breadcrumb_paths << href
      end
    else
      breadcrumb_paths << '/' + breadcrumbs[0]
    end
    return breadcrumbs, breadcrumb_paths
  end

  def dir_response(names, paths, types, breadcrumbs, breadcrumb_paths)
    # @TODO 並び替え
    {
      names: names.reverse, # ディレクトリ・ファイル一覧の配列
      paths: paths.reverse, # パスの配列
      types: types.reverse, # タイプ（ファイル/ディレクトリ）の配列
      breadcrumbs: breadcrumbs.reject(&:blank?), # パンくずの配列
      breadcrumb_paths: breadcrumb_paths, # パンくず（パス）の配列
      type: 'dir' # レスポンスのタイプ
    }
  end

  def file_response(res, breadcrumbs, breadcrumb_paths)
    # ハイライト処理
    highlight_content = []
    content = Base64.decode64(res[:content]).force_encoding('UTF-8')

    content.each_line { |line| highlight_content << line.gsub(' ', '&nbsp;') }
    highlight_content.map! { |e| e ? e : '' }
    {
      name: res[:name],
      path: res[:path],
      type: res[:type],
      content: highlight_content.reverse,
      breadcrumbs: breadcrumbs,
      breadcrumb_paths: breadcrumb_paths
    }
  end
end
