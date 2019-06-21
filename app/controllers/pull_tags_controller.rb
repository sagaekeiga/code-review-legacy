class PullTagsController < Users::BaseController
  skip_before_action :verify_authenticity_token, only: %i[update]
  def update
    pull = current_user.pulls.find(params[:pull_id])
    pull_tag = pull.pull_tags.find(params[:id])
    pull_tag.update(tag_id: params[:tag_id])
  end
end
