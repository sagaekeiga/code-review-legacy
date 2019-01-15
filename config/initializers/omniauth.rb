Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?

  provider :github,
   ENV['GITHUB_CLIENT_ID'],
   ENV['GITHUB_CLIENT_SECRET'],
   { scope: 'user:email' }

  on_failure do |env|
    # we need to setup env
    if env['omniauth.params'].present?
      env["devise.mapping"] = Devise.mappings[:reviewee]
    end

    AuthenticationsController.action(:failure).call(env)
  end

  configure do |config|
    config.path_prefix = '/auth'
    config.full_host = lambda do |env|
      protcol = Rails.env.production? ? 'https://' : 'http://'
      case env['HTTP_HOST'].split('.').first
      when 'reviewer'
        protcol + ENV['REVIEWER_DOMAIN']
      when 'app'
        protcol + ENV['WEB_DOMAIN']
      else
      end
    end
  end
end
