#
# GitHubAppからのWebhook管理
#
class Webhooks::GithubAppsController < Webhooks::BaseController
  def handle
    Github::EventBranchService.call(
      request_event: request.headers['X-GitHub-Event'],
      params: params
    )
    head 204
  end
end