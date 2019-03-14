class Reviewers::PullsController < Reviewers::BaseController
  before_action :set_pull, only: %i(show update)
  before_action :set_changed_files, only: %i(show)
  before_action :set_repo, only: %i(index show)

  def index
    @pulls =
      if params[:status] == 'closed'
        @repo.pulls.closed
      else
        @repo.pulls.open
      end
  end

  def show
    @review = Review.new
    @pull = Pull.friendly.find(params[:token]).decorate
    @pending_review = @pull.reviews.pending.first
    @double_review_comments = @pull.reviews.map { |review| review.review_comments.includes(:reviewer) }
    @reviews = @pull.reviews.where(event: %i(comment issue_comment))
  end

  private

  def set_pull
    @pull = Pull.friendly.find(params[:token] || params[:pull_token]).decorate
  end

  def set_changed_files
    @changed_files = Pull::ChangedFileDecorator.decorate_collection @pull.changed_files
  end

  def set_repo
    @repo = current_reviewer.repos.friendly.find(params[:repo_id])
  end
end
