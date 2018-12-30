require 'github/request.rb'
class Reviewers::ContentsController < Reviewers::BaseController
  before_action :set_repo, only: %i(index)

  def index
    if params[:keyword].present?
      @result = Github::Request.search_contents keyword: params[:keyword], repo: @repo
      return
    end
    if params[:type] == 'dir' || params[:type].nil?
      res = Github::Request.content repo: @repo, path: params[:path]
      @contents = Content.initializes contents: res
    else
      res = Github::Request.content repo: @repo, path: params[:path]
      @content = Content.new(
        name: res[:name],
        path: res[:path],
        content: res[:content],
        type: :file
      )
    end
  end

  private

  def set_repo
    @repo = current_reviewer.repos.friendly.find(params[:repo_id]).decorate
  end

  def sort(contents:)
    dirs = contents.select{ |content| content[:type].eql?('dir') }
    files = contents.select{ |content| content[:type].eql?('file') }
    result = []
    result << dirs
    result << files
    result.flatten!
    result
  end
end
