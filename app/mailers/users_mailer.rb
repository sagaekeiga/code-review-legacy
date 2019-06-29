class UsersMailer < ApplicationMailer
  def requests(pull_id, user_id)
    @pull = Pull.find(pull_id)
    @reviewer = User.find(user_id)
    mail(to: @reviewer.github_account.email)
  end
end
