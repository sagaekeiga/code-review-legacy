class WebDomainConstraint
  # Review Appsでは毎回ドメインが変更されるのでドメイン制約をつけない
  def self.matches?(request)
    ENV['REVIEW_APP'].present? || request.host == (ENV['WEB_DOMAIN'])
  end
end

Rails.application.routes.draw do
  #
  # webサービス用のドメイン
  #
  constraints(WebDomainConstraint) do
    # トップページ
    root 'welcome#index'
  end
end
