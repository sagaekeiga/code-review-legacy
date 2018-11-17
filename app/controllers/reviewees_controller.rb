class RevieweesController < Reviewees::BaseController
  skip_before_action :connect_github!, only: %i(integrations)

  def dashboard
    @reviewee = current_reviewee.decorate
  end

  def integrations
  end
end
