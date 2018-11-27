class ReviewerRepoMailer < ApplicationMailer
  def repo_assign_mail(repo_assign_mail)
    @repo = repo_assign_mail.repo
    @reviewer = repo_assign_mail.reviewer
    mail(subject: 'Mergeeからリポジトリをアサインがされました', to: @reviewer.email)
  end
end
