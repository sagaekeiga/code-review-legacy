class AnalyzeFilesService
  private_class_method :new

  def self.call(pull_remote_id:)
    pull = Pull.find_by(remote_id: pull_remote_id)
    return unless pull
    new(pull: pull).send(:call) if pull.repo_analysis
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
    outputs.each do |output|
      "### #{output[:message]}
      * #{output[:filename]}"
    end
    header = "## Rails Best Practice"
    header += outputs
    return unless outputs.empty?
    params = { body: outputs.to_s }.to_json
    Github::Request.issue_comment(params, pull)
  end
end
