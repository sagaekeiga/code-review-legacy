class RepoDecorator < ApplicationDecorator
  delegate_all
  # GitHub上のレポジトリへのリンクを返す
  def remote_url
    Settings.github.web_domain + object.full_name
  end

  # レポジトリアサイン削除アクションのパスを返す
  def destroy_reviewer_repo_path(reviewer)
    reviewer_repo = reviewer_repos.find_by(reviewer: reviewer)
    h.admins_reviewer_repo_path(reviewer_repo)
  end

  def name_including_orgs
    case resource_type
    when 'Org' then full_name.truncate(40)
    when 'Reviewee' then name.truncate(40)
    end
  end
end
