class Reviewers::ReposController < Reviewers::BaseController
	def show
		@repo = Repo.find(params[:id])
	end
end
