require 'github/request.rb'
class Reviewers::ReposController < Reviewers::BaseController
  before_action :set_repo, only: %i(show)

  def show
    @contents = Github::Request.contents repo: @repo
    @contents = sort contents: @contents
    @readme = Github::Request.readme repo: @repo
  end

  private

  def set_repo
    @repo = current_reviewer.repos.friendly.find(params[:id])
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
