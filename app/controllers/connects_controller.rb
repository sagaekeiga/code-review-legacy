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
    auth = ActiveSupport::HashWithIndifferentAccess.new(request.env['omniauth.auth'])
    clazz::GithubAccount.find_for_oauth(auth, resource)
    redirect_to :root
  end
end
