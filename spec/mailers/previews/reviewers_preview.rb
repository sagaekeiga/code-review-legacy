class ReviewersPreview < ActionMailer::Preview
  def pull_request_notice
    reviewer = Reviewer.first
    pull = Pull.first

    ReviewerMailer.pull_request_notice(reviewer, pull)
  end
end