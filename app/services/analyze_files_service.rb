class AnalyzeFilesService
  private_class_method :new

  def self.call(pull_remote_id:)
    return unless pull = Pull.find_by(remote_id: pull_remote_id)
    new(pull: pull).send(:call) if pull.repo.analysis
  end

  private

  def initialize(pull:)
    @pull = pull
  end

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
