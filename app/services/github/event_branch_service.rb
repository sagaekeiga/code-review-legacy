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
    case @request_event
    when 'installation_repositories', 'installation' then repository
    when 'pull_request' then pull_request
    when 'pull_request_review' then pull_request_review
    when 'pull_request_review_comment' then pull_request_review_comment
    when 'issue_comment' then issue_comment
    end
  end

  def repository
    # Add
    CreateRepoJob.perform_later(@params.to_json) if @params[:repositories_added].present? || @params[:repositories].present?
    # Remove
    if @params[:github_app][:repositories_removed].present?
      @params[:github_app][:repositories_removed].each do |repositories_removed_params|
        Repo.find_by(remote_id: repositories_removed_params[:id])&.destroy
      end
    end
  end

  def pull_request
    return unless @params.dig(:github_app, :pull_request).present?
    Pull.update_by_pull_request_event!(@params[:github_app][:pull_request])
  end

  def pull_request_review
    Review.update_by_commit_id!(@params)
  end

  def pull_request_review_comment
    if params.dig(:comment, :in_reply_to_id)
      ReviewComment.fetch_reply!(@params)
    else
      ReviewComment.fetch!(@params)
    end
  end

  def issue_comment
    @github_account = Reviewees::GithubAccount.find_by(owner_id: @params[:issue][:user][:id])
    Review.fetch_issue_comments!(@params)
  end
end