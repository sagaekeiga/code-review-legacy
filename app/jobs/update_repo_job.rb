class UpdateRepoJob < ApplicationJob
  queue_as :default

  def perform(params)
    Repo.update!(JSON.parse(params, symbolize_names: true))
  end
end
