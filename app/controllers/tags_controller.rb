class TagsController < ApplicationController
  def autocomplete
    tags = Tag.match_by(params[:term])
    render json: tags.to_json
  end
end