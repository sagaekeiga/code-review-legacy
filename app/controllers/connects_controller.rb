class ConnectsController < ApplicationController
  # GET /auth/github/callback
  def github
    callback_from :github
  end

  # GET /auth/facebook/callback
  def callback_from(_provider)
    Users::GithubAccount.find_for_oauth(JSON.parse(auth))
    redirect_to :root
  end
end
