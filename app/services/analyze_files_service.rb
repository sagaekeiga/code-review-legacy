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
    issue_comment = pull.issue_comments.find_or_initialize(status: :analysis)
    if issue_comment.persisted?
      data = Github::Request.update_issue_comment(params, pull)
      issue_comment.update(
        remote_id: data[:id],
        body: data[:body]
      )
    else
      data = Github::Request.issue_comment(params, pull)
      issue_comment.assign_attributes(
        remote_id: data[:id],
        body: data[:body]
      )
      issue_comment.save
    end
    Rails.logger.info data
  end
end
