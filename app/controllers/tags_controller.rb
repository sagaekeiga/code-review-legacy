class TagsController < ApplicationController
  def index
    tags = Tag.where('name ILIKE ?', "%#{params[:term]}%").where.not(id: current_user.tags.pluck(:id))
    render json: tags.to_json
  end
end
