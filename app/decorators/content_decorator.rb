class ContentDecorator < ApplicationDecorator
  delegate_all
  decorates :content

  def breadcrumbs
    split('/')
  end
end
