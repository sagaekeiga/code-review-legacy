class Reviewers::ReviewsController < Reviewers::BaseController
  before_action :set_review, only: %i(show edit update)
  before_action :set_pull, only: %i(view_check new create show edit update)
  before_action :check_show, only: %i(show edit)
  before_action :check_assign, only: %i(new edit show)
  before_action :set_numbers, only: %i(new show edit)
  before_action :set_commits, only: %i(new show edit)
  before_action :set_changed_files, only: %i(new create show edit)
  before_action :set_reviews, only: %i(view_check new create show edit update)

  def index
    @reviews = current_reviewer.reviews.includes(:pull).order(updated_at: :desc).decorate
  end

  def view_check
    @review = Review.new.decorate
  end

  def new
    @review = Review.new.decorate
    flash.now[:success] = t '.start_review'
  end

  def create
    # データの作成とGHAへのリクエストを分離することで例外処理に対応する
    ActiveRecord::Base.transaction do
      @review = current_reviewer.reviews.ready_to_review!(@pull, params[:review][:body])
    end
    redirect_to [:reviewers, @pull, @review], success: t('.success')
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    @review = Review.new
    flash[:danger] = t('reviewers.reviews.messages.failed')
    render :new
  end

  def show
  end

  def edit
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

  def check_assign
    unless current_reviewer.assign_to!(@pull)
      return redirect_to view_check_reviewers_pull_reviews_path(@pull), warning: t('reviewers.reviews.messages.already')
    end
  end

  def check_show
    return redirect_to reviewers_pull_review_replies_url(@pull, review_id: @review.id) if @review.approve? || @review.comment?
  end

  def set_changed_files
    @changed_files = @pull.files_changed.decorate
  end

  def set_review
    @review = current_reviewer.reviews.find(params[:id] || params[:review_id]).decorate
  end

  def set_commits
    @commits = @pull.commits.decorate
  end

  def set_numbers
    @numbers = @pull.body.scan(/#\d+/)&.map{ |num| num.delete('#').to_i }
  end

  def review_params
    params.require(:review).permit(:body)
  end

  def set_reviews
    @reviews = current_reviewer.reviews.where(pull_id: @pull.id).order(:created_at).decorate
  end
end
