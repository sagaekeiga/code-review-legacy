class ReviewersController < Reviewers::BaseController
  def dashboard
    @pulls = Repo.pulls_suitable_for(current_reviewer)
  end
end