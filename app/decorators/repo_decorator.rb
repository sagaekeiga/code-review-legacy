class RepoDecorator < ApplicationDecorator
  delegate_all
  # GitHub上のレポジトリへのリンクを返す
  def remote_url
    Settings.github.web_domain + object.full_name
  end

  # レポジトリアサイン削除アクションのパスを返す
  def destroy_reviewer_repo_path(reviewer:, repo_id:)
    reviewer_repo = reviewer_repos.find_by(reviewer: reviewer)
    h.admins_reviewer_repo_path(reviewer_repo, repo_id: repo_id)
  end

  def name_including_orgs
    case resource_type
    when 'Org' then full_name.truncate(40)
    when 'Reviewee' then name.truncate(40)
    end
  end

  def resource_name
    case resource_type
    when 'Org' then resource.login
    when 'Reviewee' then resource.nickname
    end
  end

  def resource_last_sign_in_at
    case resource_type
    when 'Org' then resource.updated_at
    when 'Reviewee' then resource.last_sign_in_at
    end
  end

  def breadcrumbs(path, type = 'dir')
    split_pathes = path.split('/')
    links = []
    split_pathes.each.with_index do |split_path, index|
      type = 'file' if File.extname(split_path).present?
      param = split_pathes[0..index].join('/')
      link = "<a href='/reviewers/repos/#{token}/contents?path=#{param}&type=#{type}'>#{split_path}</a>"
      links << link
    end
    links.join(' / ').html_safe
  end
end
