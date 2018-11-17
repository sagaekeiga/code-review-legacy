class WebDomainConstraint
  # Review Appsでは毎回ドメインが変更されるのでドメイン制約をつけない
  def self.matches?(request)
    ENV['REVIEW_APP'].present? || request.host == (ENV['WEB_DOMAIN'])
  end
end

class AdminDomainConstraint
  # Review Appsでは毎回ドメインが変更されるのでドメイン制約をつけない
  def self.matches?(request)
    ENV['REVIEW_APP'].present? || request.host == (ENV['ADMIN_DOMAIN'])
  end
end

Rails.application.routes.draw do
  scope module: :api do
    scope module: :v1 do
      namespace :github_apps do
        post :receive_webhook
      end
    end
  end

  constraints(WebDomainConstraint) do
    root to: 'welcome#index'
    get '/auth/github/callback', to: 'connects#github'

    devise_scope :reviewee do
      post '/auth/:action/callback',
        controller: 'authentications',
        constraints: { action: /github/ }
    end

    devise_scope :reviewer do
      get '/auth/:action/callback',
        controller: 'connects',
        constraints: { action: /github/ }
    end

    #
    # Reviewee
    #
    devise_for :reviewees, path: 'reviewees', controllers: {
      registrations: 'reviewees/registrations',
      confirmations: 'reviewees/confirmations',
      sessions: 'reviewees/sessions'
    }

    #
    # Reviewee
    #
    namespace :reviewees do
      get :dashboard
      get :integrations
      get 'settings/integrations'
      resources :memberships, only: %i(index create destroy update) do
        collection do
          post :suggest
          get :join
        end
      end
      resources :pulls, only: %i(index)
      resources :repos, only: %i(index update) do
        resources :contents, only: %i(index show update)
        resources :issues, only: %i(index show update)
        resources :pulls, only: %i(update)
      end
    end

    #
    # Reviewer
    #

    devise_for :reviewers, path: 'reviewers', controllers: {
      registrations: 'reviewers/registrations',
      confirmations: 'reviewers/confirmations',
      sessions: 'reviewers/sessions'
    }

    namespace :reviewers do
      get *%i(dashboard my_page integrations pending)
      get 'settings/integrations'
      resources :pulls, only: %i(show update), param: :token do
        get :files
        resources :reviews, only: %i(create show) do
          get :view_check, on: :collection
          get :file, to: 'reviews#new', on: :collection
        end
        resources :comments, only: %i(create update destroy)
        resources :changed_files, only: %i(index show)
        resources :commits, only: %i(index show)
      end
      resources :review_comments, only: %i(index create update destroy show)
      resources :repos do
        resources :contents, only: %i(index show) do
          post :search, on: :collection
        end
        resources :issues, only: %i(index show)
      end
    end

    if !Rails.env.production? && defined?(LetterOpenerWeb)
      mount LetterOpenerWeb::Engine, at: '/letter_opener'
    end

    if !Rails.env.production? && defined?(Sidekiq::Web)
      mount Sidekiq::Web => '/sidekiq'
    end
  end
  constraints(AdminDomainConstraint) do
    root to: 'admins#dashboard'
    #
    # Admin
    #
    devise_for :admins, path: 'admins', controllers: {
      registrations: 'admins/registrations',
      confirmations: 'admins/confirmations',
      sessions: 'admins/sessions'
    }
    namespace :admins do
      resources :reviews, only: %i(index show update)
      resources :reviewers, only: %i(show update)
    end
  end
  get '*path', to: 'application#render_404'
end
