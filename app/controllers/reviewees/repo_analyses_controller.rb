class Reviewees::RepoAnalysesController < Reviewees::BaseController
  before_action :set_repo, only: %i(create)
  def create
    static_analysis = StaticAnalysis.find_by(search_name: params[:search_name])
    repo_analysis = @repo.repo_analyses.new(static_analysis: static_analysis)
    repo_analysis.save
    render json: { id: repo_analysis.id }
  end

  def destroy
    static_analysis = StaticAnalysis.find_by(search_name: params[:search_name])
    repo_analysis = RepoAnalysis.find_by(static_analysis: static_analysis)
    repo_analysis.destroy
    head 204
  end

  private

  def set_repo
    @repo = Repo.friendly.find(params[:repo_id])
  end
end
