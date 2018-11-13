class ConnectsController < ApplicationController

  # GET /auth/github/callback
  def github
    callback_from :github
  end

  # GET /auth/facebook/callback
  def callback_from(_provider)
    model_type = request.env['omniauth.params']['model_type']

    clazz = case model_type
      when 'reviewee' then Reviewees
      when 'reviewer' then Reviewers
      end
    github_account = clazz::GithubAccount.find_for_oauth(request.env['omniauth.auth'])
    case model_type
    when 'reviewee'
      Reviewee.find_for_oauth(github_account, current_reviewee)
      return redirect_to :reviewees_dashboard
    when 'reviewer'
      Reviewer.find_for_oauth(github_account, current_reviewer)
      return redirect_to :reviewers_pending
    end
  end
end
