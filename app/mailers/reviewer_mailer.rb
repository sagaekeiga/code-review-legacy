class ReviewerMailer < ApplicationMailer
  # GitHub上でレビュイーがコメントした時
  def comment(reply)
    @reply = reply
    @reviewer = reply.reviewer
    @pull = reply.changed_file.pull
    mail(to: @reviewer.email)
  end

  def ok(reviewer)
    @reviewer = reviewer
    mail(to: @reviewer.email)
  end

  def approve_review(review)
    @review = review
    @reviewer = review.reviewer
    mail(to: @reviewer.email)
  end

  def refused_review(review)
    @review = review
    @reviewer = review.reviewer
    mail(to: @reviewer.email)
  end

  def repo_assign_notice(repo_assign_mail)
    @repo = repo_assign_mail.repo
    @reviewer = repo_assign_mail.reviewer
    mail(to: @reviewer.email)
  end

  def pull_request_notice(reviewer, pull)
    @pull = pull
    @reviewer = reviewer
    mail(to: @reviewer.email)
  end
end
