class RevieweesController < Reviewees::BaseController
  skip_before_action :connect_github!, only: %i(integrations)

  def dashboard
    @repos = current_reviewee.feed_for_repos.decorate
  end

  def integrations
  end
end
