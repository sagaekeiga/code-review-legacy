source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.2'
# Use sqlite3 as the database for Active Record
gem 'pg'
# Use Puma as the app server
gem 'puma', '~> 3.7'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

gem 'annotate'
gem 'bootstrap-sass', '~> 3.3.7'
gem 'carrierwave'
gem 'dotenv-rails'
gem 'config'
gem 'draper'
gem 'enum_help'
gem 'factory_bot_rails'
gem 'faker'
gem 'faker-japanese'
gem 'font-awesome-sass'
gem 'haml-rails'
gem 'httparty'
gem 'i18n-tasks'
gem 'jquery-rails'
gem 'jquery-turbolinks'
gem 'jquery-ui-rails'
gem 'json'
gem 'kaminari'
gem 'meta-tags'
gem 'paranoia'
gem 'rails-i18n'
gem 'redis'
gem 'redis-namespace'
gem 'redis-objects'
gem 'rmagick'
gem 'sidekiq'
gem 'webpacker', '~> 3.5'

# Mailer
gem 'premailer-rails'
gem 'inky-rb', require: 'inky'

# Markdown
gem 'marked-rails'
gem 'coderay'
gem 'redcarpet'
gem 'html_truncator', '~> 0.2'
gem 'rails-highlightjs'

# Auth
gem 'devise'
gem 'omniauth'
gem 'omniauth-github'

gem 'foreman'
gem 'google-analytics-rails'
gem 'sentry-raven'
gem 'friendly_id', '~> 5.1.0'
gem 'rubyzip', require: 'zip'

# Analysis
gem 'rubocop', require: false
gem 'bullet'
gem 'rails_best_practices'
gem 'brakeman', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rails-flog', require: "flog"
  gem 'database_cleaner'
  gem 'database_rewinder'
  gem 'erb2haml'
  gem 'guard-rspec'
  gem 'json_spec'
  gem 'letter_opener_web'
  gem 'rspec'
  gem 'rspec-rails'
  gem 'rspec-request_describer'
  gem 'simplecov', require: false
  gem 'timecop'
  gem 'webmock'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'hirb'
  gem 'pry-rails'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]


