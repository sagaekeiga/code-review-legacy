require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'action_cable/engine'
require 'sprockets/railtie'
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Mergee
  class Application < Rails::Application
    config.time_zone = 'Tokyo'
    config.i18n.default_locale = :ja
    config.active_record.default_timezone = :local
    config.assets.paths << config.root.join('node_modules')

    config.active_support.use_standard_json_time_format = true
    config.paths.add 'lib', eager_load: true
    config.autoload_paths << Rails.root.join('app/lib')
    config.autoload_paths << Rails.root.join('app/services')
    config.autoload_paths << Rails.root.join('app/decorators')
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
    config.dsn = ENV['SENTRY_RAVEN_URL']

    config.generators do |g|
      g.factory_bot true
      g.fixture_replacement :factory_bot
      g.test_framework :rspec
      g.model_specs true
      g.controller_specs true
      g.decorator_specs false
      g.view_specs false
      g.helper_specs false
      g.request_specs false
      g.routing_specs false
      g.jbuilder false

      g.stylesheets false
      g.javascripts false
      g.helper :irodori_helper
    end
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Don't generate system test files.
    config.generators.system_tests = nil
  end
end
