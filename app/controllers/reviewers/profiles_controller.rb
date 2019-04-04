class Reviewers::ProfilesController < Reviewers::BaseController
  def new
    @profile = current_reviewer.build_profile
  end

  def create
    @profile = current_reviewer.build_profile(profile_params)
    if @profile.save
      redirect_to :reviewers_my_page
    else
      render :new
    end
  end

  def edit
    @profile = current_reviewer.profile
  end

  def update
    @profile = current_reviewer.profile
    if @profile.update(profile_params)
      redirect_to :reviewers_my_page
    else
      render :edit
    end
  end

  private

  def profile_params
    params.require(:reviewers_profile).permit(:company, :body)
  end
end
