class Reviewers::ReviewerTagsController < Reviewers::BaseController
  skip_before_action :set_skill!, only: %i(update)
  skip_before_action :check_reviewer_status, only: %i(update)
  def update
    if current_reviewer.create_or_destroy_tags(params[:reviewer])
      redirect_to reviewers_dashboard_url, success: t('.success')
    else
      render 'reviewer/skill'
    end
  end

  def destroy
    reviewer_tag = current_reviewer.reviewer_tags.find(params[:id])
    reviewer_tag.destroy
    head 204
  end
end
