class Reviewees::AnalysesController < Reviewees::BaseController
  before_action :set_repo
  def index
  end

  private

  def set_repo
    @repo = Repo.friendly.find(params[:repo_id])
  end
end
