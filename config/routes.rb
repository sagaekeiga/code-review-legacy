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
  namespace :webhooks do
    namespace :github_apps do
      post :handle
    end
  end
  #
  # webサービス用のドメイン
  #
  constraints(WebDomainConstraint) do
    # トップページ
    root 'welcome#index'


    get :dashboard, to: 'users#dashboard'

    resources :repos, only: %i(show)
    resources :pulls, only: %i(update)
    resources :pull_tags, only: %i(update)
    resources :review_requests, only: %i(create)
    resources :feed, only: %i(index)

    devise_for :users, path: 'users', controllers: {
      registrations: 'users/registrations',
      sessions: 'users/sessions',
      omniauth_callbacks: 'users/omniauth_callbacks'
    }

    devise_scope :user do
      get 'sign_in', to: 'users/sessions#new'
      get 'sign_out', to: 'users/sessions#destroy'
    end

    if !Rails.env.production? && defined?(LetterOpenerWeb)
      mount LetterOpenerWeb::Engine, at: '/letter_opener'
    end
  end

  #
  # 管理画面用のドメイン
  #
  constraints(AdminDomainConstraint) do
    # トップページ
    root to: 'admins#dashboard'


    # get :dashboard, to: 'admins#dashboard'

    # resources :repos, only: %i(show)
    # resources :pulls, only: %i(update)
    # resources :pull_tags, only: %i(update)
    # resources :review_requests, only: %i(create)
    # resources :feed, only: %i(index)

    devise_for :admins, path: 'admins', controllers: {
      registrations: 'admins/registrations',
      sessions: 'admins/sessions',
      confirmations: 'admins/confirmations'
    }
  end
end
