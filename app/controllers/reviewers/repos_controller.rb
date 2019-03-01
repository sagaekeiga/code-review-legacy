require 'github/request.rb'
class Reviewers::ReposController < Reviewers::BaseController
  before_action :set_repo, only: %i(show download)

  def show
    @contents = Github::Request.contents repo: @repo
    @contents = sort contents: @contents
    @readme = Github::Request.readme repo: @repo
  end

  # POST /reviewers/repos/:repo_id/download
  def download
    pull = @repo.pulls.friendly.find(params[:pull_token])
    zip = Github::Request.repo_archive(repo: @repo, pull: pull)
    zipfile = Tempfile.new('file')
    zipfile.binmode
    zipfile.write(zip.body)
    zipfile.close
    send_data(File.read(zipfile.path), filename: "pr-#{pull.commits.last.sha}.zip")
  end

  private

  def set_repo
    @repo = current_reviewer.repos.friendly.find(params[:id] || params[:repo_id])
  end

  def sort(contents:)
    dirs = contents.select { |content| content[:type].eql?('dir') }
    files = contents.select { |content| content[:type].eql?('file') }
    result = []
    result << dirs
    result << files
    result.flatten!
    result
  end
end
