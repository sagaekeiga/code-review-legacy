class FeedbacksController < ApplicationController
  def create
    Feedback::Request.feedback_exec(
      {
        url: params[:feedback][:url],
        body: params[:feedback][:body]
      }
    )
    render json: { status: 'ok' }
  end
end
