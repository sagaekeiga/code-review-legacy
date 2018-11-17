#
# GitHubAppからのリクエスト管理
#
class Api::V1::GithubAppsController < ApplicationController
  skip_before_action :verify_authenticity_token
  # @TODO IP制限かける

  # POST /github_apps/receive_webhook
  def receive_webhook
    case request.headers['X-GitHub-Event']
    when 'installation_repositories', 'installation'
      # Add
      CreateRepoJob.perform_later(params.to_json) if params[:repositories_added].present? || params[:repositories].present?
      # Remove
      if params[:github_app][:repositories_removed].present?
        params[:github_app][:repositories_removed].each do |repositories_removed_params|
          Repo.find_by(remote_id: repositories_removed_params[:id])&.destroy
        end
        status = true
      end
    when 'issues'
      status = Issue.update_by_issue_event!(params)
    when 'pull_request'
      status = Pull.update_by_pull_request_event!(params[:github_app][:pull_request]) if params.dig(:github_app, :pull_request).present?
    when 'pull_request_review'
      # レビュー内容取得
      status = Review.update_by_commit_id!(params)
    when 'pull_request_review_comment'
      # コメント取得(レビュー時のコメント部分も含む)
      status = 
        if params.dig(:comment, :in_reply_to_id)
          status = ReviewComment.fetch_reply!(params)
        else
          status = ReviewComment.fetch!(params)
        end
    when 'issue_comment'
      @github_account = Reviewees::GithubAccount.find_by(owner_id: params[:issue][:user][:id])
      status = Review.fetch_issue_comments!(params)
    end
    if status
      return response_success(controller_name, action_name)
    else
      return response_internal_server_error
    end
  end
end
