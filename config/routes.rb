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

    namespace :users do
      get :dashboard
    end

    resources :repos, only: %i(show)
    resources :pulls, only: %i(update)

    devise_for :users, path: 'users', controllers: {
      registrations: 'users/registrations',
      omniauth_callbacks: 'users/omniauth_callbacks'
    }
  end
end
