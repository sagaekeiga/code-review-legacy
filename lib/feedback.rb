module Feedback
  class Request
    include HTTParty
    class << self
      def feedback_exec(params)
        post "#{ENV['FEEDBACK_POST_URL']}/api/feedbacks", body: params
      end
    end
  end
end
