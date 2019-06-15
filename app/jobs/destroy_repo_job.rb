class DestroyRepoJob < ApplicationJob
  queue_as :default

  def perform(params)
    params = JSON.parse params, symbolize_names: true
    target_repositories = params[:github_app][:repositories_removed]
    target_repositories.each { |repo| Repo.find_and_destroy_by(remote_id: repo[:id]) }
  end
end
