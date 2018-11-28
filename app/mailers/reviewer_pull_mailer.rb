class ReviewerPullMailer < ApplicationMailer
  def pull_assign_notice(pull_assign_mail)
    @repo = pull_assign_mail.pull
    @reviewer = pull_assign_mail.reviewer
    mail(subject: 'Mergeeからリポジトリをアサインがされました', to: @reviewer.email)
  end
end
