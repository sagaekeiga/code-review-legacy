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
    Pull.update_by_pull_request_event!(@params[:github_app][:pull_request]) if present_pull_request?
  end

  def present_pull_request?
    @params.dig(:github_app, :pull_request).present?
  end

  def pull_request_review
    Review.update_by_commit_id!(@params)
  end

  def pull_request_review_comment
    if reply?
      ReviewComment.fetch_reply!(@params)
    else
      ReviewComment.fetch!(@params)
    end
  end

  def reply?
    @params.dig(:comment, :in_reply_to_id).present?
  end
end
