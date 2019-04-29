class Reviewers::ReviewsController < Reviewers::BaseController
  before_action :set_review, only: %i(update)
  before_action :set_pull, only: %i(new create update)
  before_action :set_repo, only: %i(new)
  before_action :check_assign, only: %i(new create update)
  before_action :check_pr, only: %i(new create update)
  before_action :set_changed_files, only: %i(new create)
  before_action :set_reviews, only: %i(new create update)

  def new
    @review = Review.new
  end

  def create
    ActiveRecord::Base.transaction do
      @review = current_reviewer.reviews.ready_to_review!(@pull, params[:review][:body])
    end
    redirect_to [:reviewers, @pull], success: t('.success')
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    @review = Review.new
    flash[:danger] = t('reviewers.reviews.messages.failed')
    render :new
  end

  def update
    if @review.update(review_params)
      redirect_to [:reviewers, @pull, @review], success: t('reviewers.reviews.messages.updated')
    else
      render :edit
    end
  end

  private

  def set_pull
    @pull = Pull.friendly.find(params[:pull_token]).decorate
  end

  def set_repo
    @repo = @pull.repo
  end

  def check_assign
    return redirect_to [:reviewers, @repo, @pull, :changed_files] unless current_reviewer.assigned?(@pull)
  end

  def check_pr
    return redirect_to [:reviewers, @repo, @pull], alert: t('reviewers.reviews.alerts.check_pr.danger') if @pull.completed?
  end

  def set_changed_files
    @changed_files = Pull::ChangedFileDecorator.decorate_collection @pull.changed_files
  end

  def set_review
    @review = current_reviewer.reviews.find(params[:id] || params[:review_id]).decorate
  end

  def review_params
    params.require(:review).permit(:body)
  end

  def set_reviews
    @reviews = current_reviewer.reviews.where(pull_id: @pull.id).order(:created_at)
  end
end
