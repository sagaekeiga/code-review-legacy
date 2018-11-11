class ConnectsController < ApplicationController

  # GET /auth/github/callback
  def github
    callback_from :github
  end
   # GET /auth/facebook/callback
  def callback_from(_provider)
    ActiveRecord::Base.transaction do
      @reviewee = current_reviewee.connect_to_github(request.env['omniauth.auth']) if reviewee_signed_in?
      @reviewer = current_reviewer.connect_to_github(request.env['omniauth.auth']) if reviewer_signed_in?
    end
    return redirect_to reviewees_dashboard_url, success: t('views.github.connect.success') if reviewee_signed_in?
    return redirect_to reviewers_dashboard_url, success: t('views.github.connect.success') if reviewer_signed_in?
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    return redirect_to new_reviewee_registration_url, danger: (t 'views.failed', resource: I18n.t('activerecord.models.github_info')) if reviewee_signed_in?
    return redirect_to new_reviewer_registration_url, danger: (t 'views.failed', resource: I18n.t('activerecord.models.github_info')) if reviewer_signed_in?
  end
   def setup
    if params[:scope].eql?('read:org')
      request.env['omniauth.strategy'].options[:scope] = 'read:org'
    end
    render json: 'Setup complete.', status: 404
  end
end
