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

  scope module: :api do
    scope module: :v1 do
      namespace :github_apps do
        post :receive_webhook
      end
    end
  end

  constraints(WebDomainConstraint) do
    root to: 'welcome#index'
    get '/term', to: 'welcome#term'
    get '/privacy', to: 'welcome#privacy'
    get '/auth/github/callback', to: 'connects#github'

    devise_for :reviewees, path: 'reviewees', controllers: {
      registrations: 'reviewees/registrations',
      confirmations: 'reviewees/confirmations',
      sessions: 'reviewees/sessions'
    }

    namespace :reviewees do
      get :dashboard
      get :integrations
      get 'settings/integrations'
      resources :pulls, only: %i(index)
      resources :repos, shallow: true, only: %i(index show) do
        resources :pulls, only: %i(update)
      end
    end

    if !Rails.env.production? && defined?(LetterOpenerWeb)
      mount LetterOpenerWeb::Engine, at: '/letter_opener'
    end

    if !Rails.env.production? && defined?(Sidekiq::Web)
      mount Sidekiq::Web => '/sidekiq'
    end

  end

  constraints(ReviewerDomainConstraint) do
    root to: 'reviewers#dashboard'
    get '/auth/github/callback', to: 'connects#github'
    post '/feedbacks', to: 'feedbacks#create'

    devise_for :reviewers, path: 'reviewers', controllers: {
      registrations: 'reviewers/registrations',
      confirmations: 'reviewers/confirmations',
      sessions: 'reviewers/sessions'
    }

    namespace :reviewers do
      get *%i(dashboard integrations pending)
      get 'settings/integrations'
      resources :pulls, only: %i(show), param: :token do
        get :files
        resources :reviews, only: %i(create show edit update) do
          collection do
            get :view_check
            get :file, to: 'reviews#new'
          end
          resources :replies, only: %i(index create update), shallow: true
        end
        resources :comments, only: %i(create update destroy)
        resources :changed_files, only: %i(index show)
        resources :commits, only: %i(index show)
      end
      resources :send_mails, only: %i(create)
      resources :review_comments, only: %i(create update destroy show)
      namespace :github do
        resource :changed_files, only: %i(show)
        resources :issues, only: %i(index)
      end
      resources :repos, only: %i(show) do
        resources :contents, only: %i(index)
      end
      resources :reviews, only: %i(index)
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
      resources :reviewers, only: %i(show update)
      resources :repos, only: %i(index show) do
        resources :reviewer_repos, shallow: :true, only: %i(create destroy)
      end
      resources :pulls, only: %i(show index) do
        resources :reviewer_pulls, only: %i(create destroy)
      end
    end
  end
  get '*path', to: 'application#render_404'
end
