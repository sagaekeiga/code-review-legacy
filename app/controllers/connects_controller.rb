class ConnectsController < ApplicationController

  # GET /auth/github/callback
  def github
    callback_from :github
  end

  # GET /auth/facebook/callback
  def callback_from(_provider)
    model_type = request.env['omniauth.params']['model_type']
    clazz, resource = case model_type
      when 'reviewee'
        [Reviewees, current_reviewee]
      when 'reviewer'
        [Reviewers, current_reviewer]
      end

    clazz::GithubAccount.find_for_oauth(request.env['omniauth.auth'], resource) if _provider.eql?(:github)

    case model_type
    when 'reviewee'
      return redirect_to :reviewees_dashboard
    when 'reviewer'
      return redirect_to :reviewers_pending
    end
  end
end
