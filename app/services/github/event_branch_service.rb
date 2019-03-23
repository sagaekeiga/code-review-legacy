class Github::EventBranchService
  private_class_method :new

  def self.call(request_event:, params:)
    new(request_event: request_event, params: params).send(:call)
  end

  private

  def initialize(request_event:, params:)
    @request_event = request_event
    @params = params
  end

  #
  # Eventごとに処理を走らせる
  #
  def call
    case @request_event.to_sym
    when :installation_repositories, :installation then repository
    when :pull_request then pull_request
    when :pull_request_review then pull_request_review
    when :pull_request_review_comment then pull_request_review_comment
    when :check_suite then check_suite
    end
  end

  def repository
    if add_repository?
      CreateRepoJob.perform_later(@params.to_json)
    elsif remove_repository?
      DestroyRepoJob.perform_later(@params.to_json)
    end
  end

  def add_repository?
    @params[:repositories_added].present? || @params[:repositories].present?
  end

  def remove_repository?
    @params[:github_app][:repositories_removed].present?
  end

  def pull_request
    return unless present_pull_request?
    Pull.update_by_pull_request_event!(@params[:github_app][:pull_request])
    AnalyzeFilesService.call(params: @params)
  end

  def present_pull_request?
    @params.dig(:github_app, :pull_request).present?
  end

  def pull_request_review
    Review.update_by_commit_id!(@params)
  end

  def pull_request_review_comment
    return ReviewComment.fetch_changes!(@param) if changed_review_comment?
    ReviewComment.fetch_reply!(@params) if reply?
  end

  def reply?
    @params.dig(:comment, :in_reply_to_id).present?
  end

  def changed_review_comment?
    @params.dig(:changes).present?
  end
end
