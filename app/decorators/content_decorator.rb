class ContentDecorator < ApplicationDecorator
  delegate_all
  decorates :content
end
