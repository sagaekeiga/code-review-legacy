require 'github/request.rb'
class Reviewers::Github::ContentsController < Reviewers::BaseController
  before_action :set_repo, only: %i(get_contents)

  # 第一階層のレポジトリファイルを取得
  def get_contents
    breadcrumbs, breadcrumb_paths = new_breadcrumbs
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
        dir_response(names, paths, types, breadcrumbs, breadcrumb_paths)
      when 'file'
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
    render json: res
  end

  # def get_parent_dirs
  #   parent_dir = params[:path].gsub(%r"#{params[:name]}$",'')
  #   Rails.logger.debug parent_dir
  #   res = Github::Request.github_exec_fetch_repo_contents!(@repo, parent_dir)
  #   names, paths, types = [], [], []
  #   res.each do |content|
  #     content = ActiveSupport::HashWithIndifferentAccess.new(content)
  #     names << content[:name]
  #     paths << content[:path]
  #     types << content[:type]
  #   end
  #   render json: dir_response(names, paths, types)
  # end

  private

  def set_repo
    @repo = Repo.find(params[:repo_id])
  end

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
    Rails.logger.debug "breadcrumbs: #{breadcrumbs}"
    if breadcrumbs.size > 1
      breadcrumbs.each.with_index do |breadcrumb, index|
        Rails.logger.debug breadcrumb
        href = ''
        index = index.to_i + 1
        index.times do |time|
          time = time if (index.to_i - 1).eql?(time.to_i)
          href += '/' + breadcrumbs[time.to_i]
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
    {
      names: names.reverse,
      paths: paths.reverse,
      types: types.reverse,
      breadcrumbs: breadcrumbs,
      breadcrumb_paths: breadcrumb_paths,
      type: 'dir'
    }
  end

  def file_response(res, breadcrumbs, breadcrumb_paths)
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
