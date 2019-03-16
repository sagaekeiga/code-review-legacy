class AnalyzeFilesService
  private_class_method :new

  def self.call(pull:)
    new(pull: pull).send(:call)
  end

  private

  def initialize(pull:)
    @pull = pull
  end

  #
  # Eventごとに処理を走らせる
  #
  def call
    rails_best_practices pull: @pull
  end

  def rails_best_practices(pull:)
    analyzer = RailsBestPractices::Analyzer.new(ARGV.first, {}, pull: @pull)
    analyzer.analyze
    outputs = analyzer.output
    params = { body: outputs.to_s }.to_json
    Github::Request.issue_comment(params, pull)
  end
end