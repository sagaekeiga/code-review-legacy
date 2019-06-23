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
    when :pull_request then pull_request
    when :installation_repositories, :installation, :repository then repository
    end
  end

  def repository
    CreateRepoJob.perform_later(@params.to_json) if add_repository?
    DestroyRepoJob.perform_later(@params.to_json) if remove_repository?
    UpdateRepoJob.perform_later(@params.to_json) if update_repository?
  end

  def pull_request
    return unless present_pull_request?

    Pull.update_by_pull_request_event!(@params[:github_app][:pull_request])
  end

  def present_pull_request?
    @params.dig(:github_app, :pull_request).present?
  end

  def add_repository?
    @params[:repositories_added].present? || @params[:repositories].present?
  end

  def remove_repository?
    @params[:github_app][:repositories_removed].present?
  end

  def update_repository?
    @params[:changes].present?
  end
end
