class Reviewers::ReviewsController < Reviewers::BaseController
  before_action :set_review, only: %i(show update)
  before_action :set_pull, only: %i(new create show update)
  before_action :set_repo, only: %i(new)
  before_action :check_show, only: %i(show)
  before_action :check_assign, only: %i(new show)
  before_action :set_commits, only: %i(show)
  before_action :set_changed_files, only: %i(new create show)
  before_action :set_reviews, only: %i(new create show update)

  def new
    @review = Review.new
  end

  def create
    # データの作成とGHAへのリクエストを分離することで例外処理に対応する
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

  def show
    @repo = @pull.repo
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

  def check_show
    return redirect_to reviewers_pull_review_replies_url(@pull, review_id: @review.id) if @review.approve? || @review.comment?
  end

  def set_changed_files
    @changed_files = Pull::ChangedFileDecorator.decorate_collection @pull.changed_files
  end

  def set_review
    @review = current_reviewer.reviews.find(params[:id] || params[:review_id]).decorate
  end

  def set_commits
    @commits = Pull::CommitDecorator.decorate_collection @pull.commits
  end

  def review_params
    params.require(:review).permit(:body)
  end

  def set_reviews
    @reviews = current_reviewer.reviews.where(pull_id: @pull.id).order(:created_at)
  end
end
