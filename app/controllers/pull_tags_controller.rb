class PullTagsController < Users::BaseController
  skip_before_action :verify_authenticity_token, only: %i[update]
  def update
    pull_tag = PullTag.find(params[:id])
    pull_tag.update(tag_id: params[:tag_id])
  end
end
