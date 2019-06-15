class WebDomainConstraint
  # Review Appsでは毎回ドメインが変更されるのでドメイン制約をつけない
  def self.matches?(request)
    ENV['REVIEW_APP'].present? || request.host == (ENV['WEB_DOMAIN'])
  end
end

class ReviewerDomainConstraint
  # Review Appsでは毎回ドメインが変更されるのでドメイン制約をつけない
  def self.matches?(request)
    ENV['REVIEW_APP'].present? || request.host == (ENV['REVIEWER_DOMAIN'])
  end
end

class AdminDomainConstraint
  # Review Appsでは毎回ドメインが変更されるのでドメイン制約をつけない
  def self.matches?(request)
    ENV['REVIEW_APP'].present? || request.host == (ENV['ADMIN_DOMAIN'])
  end
end

Rails.application.routes.draw do

  namespace :webhooks do
    namespace :github_apps do
      post :handle
    end
  end

  constraints(WebDomainConstraint) do
    root to: 'welcome#index'
    get '/auth/github/callback', to: 'connects#github'

    devise_for :users, path: 'users', controllers: {
      registrations: 'users/registrations',
      confirmations: 'users/confirmations',
      sessions: 'users/sessions'
    }

    namespace :users do
      get :dashboard
      get :integrations
      get 'settings/integrations'
      resources :repos, shallow: true, only: %i(index show) do
        resources :pulls, only: %i(update)
        get :download, on: :collection
        put :template
        get :settings
        resources :repo_analyses, only: %i(create destroy)
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
      resources :reviews, only: %i(index show update destroy)
      resources :users, only: %i(index show)
      resources :orgs, only: %i(index show) do
        resources :user_orgs, shallow: :true, only: %i(create destroy)
      end
    end

    as :user do
      post 'user/sso' => 'users/sessions#sso', as: :user_sso
    end
  end
  get '*path', to: 'application#render_404'
end
