class AuthenticationsController < ApplicationController

  # GET /auth/github/callback
  def callback
    model_type = request.env['omniauth.params']['model_type']

    clazz = case model_type
      when 'reviewee' then Reviewees
      when 'reviewer' then Reviewers
      end

    github_account = clazz::GithubAccount.find_for_oauth(request.env['omniauth.auth'])
    case model_type
    when 'reviewee'
      reviewee = Reviewee.find_for_oauth(github_account)
      sign_in reviewee, event: :authentication
      return redirect_to :reviewees_dashboard
    when 'reviewer'
      reviewer = Reviewer.find_for_oauth(github_account)
      sign_in reviewer, event: :authentication
      return redirect_to :reviewers_dashboard
    end
  end
end
