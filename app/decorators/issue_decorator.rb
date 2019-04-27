class IssueDecorator < ApplicationDecorator
  delegate_all

  def number
    "##{model.number}"
  end
end
