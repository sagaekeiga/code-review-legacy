class Reviewers::ReviewsController < Reviewers::BaseController
  before_action :set_review, only: %i(show edit update replies)
  before_action :set_pull, only: %i(view_check new create show edit update replies)
  before_action :check_assign, only: %i(new)
  before_action :set_numbers, only: %i(new show edit replies)
  before_action :set_commits, only: %i(new show edit replies)
  before_action :set_changed_files, only: %i(new create show edit replies)

  def view_check
  end

  def new
    @review = Review.new
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
    flash[:danger] = 'レビューに失敗しました'
    render :new
  end

  def show
  end

  def edit
  end

  def update
    if @review.update(review_params)
      redirect_to [:reviewers, @pull, @review], success: '更新しました。'
    else
      render :edit
    end
  end

  def replies
    @reviews = @pull.reviews.where(event: %i(comment issue_comment))
  end

  private

  def set_pull
    @pull = Pull.friendly.find(params[:pull_token]).decorate
  end

  def check_assign
    unless current_reviewer.assign_to!(@pull)
      flash.now[:warning] = 'すでに他のユーザーがアサインしています'
      return render :view_check
    end
    flash.now[:success] = 'アサインしました'
  end

  def set_changed_files
    @changed_files = @pull.files_changed.decorate
  end

  def set_review
    @review = current_reviewer.reviews.find(params[:id] || params[:review_id])
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
end
