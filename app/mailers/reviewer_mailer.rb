class ReviewerMailer < ApplicationMailer
  # GitHub上でレビュイーがコメントした時
  def comment(reply)
    @reply = reply
    @reviewer = reply.reviewer
    @pull = reply.changed_file.pull
    mail(subject: t('.title'), to: @reviewer.email)
  end

  def issue_comment(review)
    @review = review
    @reviewer = review.pull.reviewer
    @pull = review.pull
    mail(subject: t('.title'), to: @reviewer.email)
  end

  def ok(reviewer)
    @reviewer = reviewer
    mail(subject: '審査を通過しました。', to: @reviewer.email)
  end

  def approve_review(review)
    @review = review
    @reviewer = review.reviewer
    mail(subject: 'レビューが審査を通過しました。', to: @reviewer.email)
  end

  def refused_review(review)
    @review = review
    @reviewer = review.reviewer
    mail(subject: 'レビューが審査を通過できませんでした。', to: @reviewer.email)
  end

  def repo_assign_notice(repo_assign_mail)
    @repo = repo_assign_mail.repo
    @reviewer = repo_assign_mail.reviewer
    mail(subject: 'Mergeeからリポジトリをアサインがされました', to: @reviewer.email)
  end

  def pull_request_notice(reviewer, pull)
    @pull = pull
    @reviewer = reviewer
    mail(subject: 'Pullrequestがレビューリクエストされました', to: @reviewer.email)
  end
end
