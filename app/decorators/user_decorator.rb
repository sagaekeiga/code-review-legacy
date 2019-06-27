class UserDecorator < ApplicationDecorator
  delegate_all
  def html_url
    "#{Settings.github.web.home}/#{nickname}"
  end
end
