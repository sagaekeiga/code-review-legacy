class Reviewers::ReviewsController < Reviewers::BaseController
  before_action :set_review, only: %i(show)
  before_action :set_pull, only: %i(view_check new create show)
  before_action :set_commits, only: %i(new show)
  before_action :set_changed_files, only: %i(new create show)

  def view_check
  end

  # GET /reviewers/pulls/:pull_id/reviews/file
  def new
    @review = Review.new
    numbers = @pull.body.scan(/#\d+/)&.map{ |num| num.delete('#').to_i }
    # @TODO issueの取得
  end

  # POST /reviewers/pulls/:pull_id/reviews
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

  private

  def set_pull
    @pull = Pull.friendly.find(params[:pull_token])
  end

  def set_changed_files
    @changed_files = @pull.files_changed.decorate
  end

  def set_review
    @review = current_reviewer.reviews.find(params[:id])
  end

  def set_commits
    @commits = @pull.commits.decorate
  end
end
