class UserTagsController < Users::BaseController
  def create
    tag = Tag.find_by(name: params[:name])
    return render json: { success: false } if tag.nil?
    user_tag =  tag.user_tags.new(user: current_user)
    return render json: { success: user_tag.save, tag: tag }
  end
end
