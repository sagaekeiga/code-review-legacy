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
    return unless outputs.present?
    outputs = outputs.map do |output|
      "### #{output[:message]}
      * #{output[:filename]}"
    end
    params = { body: I18n.t('analysis.template', rbp_outputs: outputs.join ).gsub('"', '').to_s }.to_json
    data = Github::Request.issue_comment(params, pull)
    Rails.logger.info data
    pull.issue_comments.create(
      remote_id: data[:id],
      status: :analysis,
      body: data[:body]
    )
  end
end
