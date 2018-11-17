class RevieweesController < Reviewees::BaseController
  skip_before_action :connect_github!, only: %i(integrations)

  def dashboard
    @repos = current_reviewee.repos
  end

  def integrations
  end
end
