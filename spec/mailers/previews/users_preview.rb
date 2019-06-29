# Preview all emails at http://code-review.test/rails/mailers/users
class UsersPreview < ActionMailer::Preview
  # http://code-review.test/rails/mailers/users/requests
  def requests
    reviewer = User.first
    pull = Pull.first

    UsersMailer.requests(pull.id, reviewer.id)
  end
end
