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
    when :integration_installation_repositories, :installation_repositories, :installation then repository
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
end
