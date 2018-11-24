class ReviewDecorator < ApplicationDecorator
  delegate_all
  def trimed_commit_id
    remote_id[0...10]
  end

  def step_image
    persisted? ? 'unchecked.png' : 'checked.png'
  end

  def check_pass_review
    (approve? || comment?) ? 'active' : ''
  end

  def check_progress
    remote_id.present? ? remote_id : '作業中'
  end
end
