class AnalyzeCodeJob < ApplicationJob
  queue_as :default

  def perform(params)
    AnalyzeFilesService.call(params: params)
  end
end
