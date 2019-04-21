class Reviewees::ReposController < Reviewees::BaseController
  before_action :set_repo, only: %i(update show template settings)

  def index
    @repos = current_reviewee.viewable_repos.page(params[:page])
  end

  def show
    @pulls = @repo.pulls.order(remote_created_at: :desc).includes(:pull_tags, :tags)
  end

  def download
    filepath = Rails.root.join('public', 'templates', 'PULL_REQUEST_TEMPLATE.md')
    stat = File.stat(filepath)
    send_file(filepath, filename: 'PULL_REQUEST_TEMPLATE.md', length: stat.size)
  end

  def template
    @repo.update(template: true)
    redirect_to [:reviewees, @repo], success: '設定を完了しました'
  end

  def settings
  end

  private

  def set_repo
    @repo = Repo.friendly.find(params[:id] || params[:repo_id]).decorate
  end
end
