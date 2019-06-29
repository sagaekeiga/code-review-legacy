class WebDomainConstraint
  # Review Appsでは毎回ドメインが変更されるのでドメイン制約をつけない
  def self.matches?(request)
    ENV['REVIEW_APP'].present? || request.host == (ENV['WEB_DOMAIN'])
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
      omniauth_callbacks: 'users/omniauth_callbacks'
    }

    if !Rails.env.production? && defined?(LetterOpenerWeb)
      mount LetterOpenerWeb::Engine, at: '/letter_opener'
    end
  end
end
