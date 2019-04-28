class ReviewDecorator < ApplicationDecorator
  delegate_all
  def label_color
    if pending?
      'warning'
    else
      'success'
    end
  end
end
