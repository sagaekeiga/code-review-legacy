class PullDecorator < ApplicationDecorator
  delegate_all
  # GitHub上のプルリクエストへのリンクを返す
  def remote_url
    "https://github.com/#{full_name}/pull/#{number}"
  end
end
