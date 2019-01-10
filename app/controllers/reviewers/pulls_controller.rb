class Reviewers::PullsController < Reviewers::BaseController
  before_action :set_pull, only: %i(show update)
  before_action :set_changed_files, only: %i(show)

  def show
    @review = Review.new
    @pull = Pull.includes(changed_files: :review_comments).order('review_comments.created_at asc').friendly.find(params[:token]).decorate
    @pending_review = @pull.reviews.pending.first
    @double_review_comments = @pull.changed_files.map { |changed_file| changed_file.review_comments.includes(:reviewer) }
    @reviews = @pull.reviews.where(event: %i(comment issue_comment))
  end

  private

  def set_pull
    @pull = Pull.friendly.find(params[:token] || params[:pull_token]).decorate
  end

  def set_changed_files
    @changed_files = @pull.files_changed.decorate
  end
end
