class ReviewDecorator < ApplicationDecorator
  delegate_all
  def path
    case event
    when 'pending'
      h.reviewers_pull_review_path(pull, object)
    when 'comment'
      h.reviewers_pull_review_replies_path(pull, object)
    end
  end
end
