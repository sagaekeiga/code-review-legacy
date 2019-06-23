class RepoDecorator < ApplicationDecorator
  delegate_all
  # GitHub上のリポジトリへのリンクを返す
  def remote_url
    "https://github.com/#{full_name}"
  end
end
