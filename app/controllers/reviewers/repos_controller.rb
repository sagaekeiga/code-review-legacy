class Reviewers::ReposController < Reviewers::BaseController
  before_action :set_repo, only: %i(show download)

  def show
    @readme = @repo.readme
    @languages = @repo.languages
    @language_sum_lines = @languages.map(&:lines).sum
  end

  # POST /reviewers/repos/:repo_id/download
  def download
    pull = params[:pull_token].present? ? @repo.pulls.friendly.find(params[:pull_token]) : nil
    zip = Github::Request.repo_archive(repo: @repo, pull: pull)
    zipfile = Tempfile.new('file')
    zipfile.binmode
    zipfile.write(zip.body)
    zipfile.close
    filename = pull.present? ? "pr-#{pull.commits.last.sha}.zip" : "master.zip"
    send_data(File.read(zipfile.path), filename: filename)
  end

  private

  def set_repo
    @repo = current_reviewer.repos.friendly.find(params[:id] || params[:repo_id])
  end
end
