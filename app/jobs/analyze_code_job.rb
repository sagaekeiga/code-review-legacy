class AnalyzeCodeJob < ApplicationJob
  queue_as :default

  def perform(params)
    AnalyzeFilesService.call(params: ActiveSupport::HashWithIndifferentAccess.new(JSON.parse(params)))
  end
end
