class AdminMailer < ApplicationMailer
  def slack_mail(slack_mail)
    @slack_mail = slack_mail.email
    @reviewer = slack_mail.reviewer
    mail(to: ENV['ADMIN_CONTACT'])
  end

  def review(review_id)
    @review = Review.find(review_id)
    @reviewer = @review.reviewer
    mail(to: ENV['ADMIN_CONTACT'])
  end
end
