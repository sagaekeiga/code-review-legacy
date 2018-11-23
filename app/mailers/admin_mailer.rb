class AdminMailer < ApplicationMailer
  def slack_mail(slack_mail)
    @slack_mail = slack_mail.email
    @reviewer = slack_mail.reviewer
    mail(subject: 'レビュワーからSlackのメールアドレスが届きました', to: ENV['ADMIN_CONTACT'])
  end
end
