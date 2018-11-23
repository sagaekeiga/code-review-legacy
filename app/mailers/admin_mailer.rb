class AdminMailer < ApplicationMailer
  def slack_mail(instance)
    p '==============='
    @slack_mail = instance.email
    @reviewer = instance.reviewer
    mail(subject: 'レビュワーからSlackのメールアドレスが届きました', to: ENV['ADMIN_CONTACT'])
  end
end
