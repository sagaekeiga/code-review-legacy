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
      resources :repos, shallow: true, only: %i(index show) do
        resources :pulls, only: %i(update)
        get :download, on: :collection
        put :template
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

    devise_for :reviewers, path: 'reviewers', controllers: {
      registrations: 'reviewers/registrations',
      confirmations: 'reviewers/confirmations',
      sessions: 'reviewers/sessions'
    }

    namespace :reviewers do
      get *%i(dashboard integrations pending check_list)
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
      end
      resources :send_mails, only: %i(create)
      resources :review_comments, only: %i(create update destroy show)
      namespace :github do
        resources :review_comments, only: %i(update)
        resources :issues, only: %i(index)
      end
      resources :repos, only: %i(show) do
        post :download
        resources :contents, only: %i(index)
        resources :pulls, only: %i(index show), param: :token do
          resources :commits, only: %i(index show), param: :sha
          resources :changed_files, only: %i(index show), param: :sha
        end
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
      resources :reviewers, only: %i(index show edit update)
      resources :reviewees, only: %i(index show)
      resources :orgs, only: %i(index show) do
        resources :reviewee_orgs, shallow: :true, only: %i(create destroy)
      end
      resources :repos, only: %i(index show) do
        resources :reviewer_repos, shallow: :true, only: %i(create destroy)
      end
      resources :pulls, only: %i(show index) do
        resources :reviewer_pulls, only: %i(create destroy)
      end
    end

    as :reviewer do
      post 'reviewer/sso' => 'reviewers/sessions#sso', as: :reviewer_sso
    end
    as :reviewee do
      post 'reviewee/sso' => 'reviewees/sessions#sso', as: :reviewee_sso
    end
  end
  get '*path', to: 'application#render_404'
end
