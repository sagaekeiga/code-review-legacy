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
    params =
      if outputs.present?
        messages = outputs.map { |output| output[:message] }.uniq
        format_outputs = messages.map do |message|
          target_outputs = outputs.select { |output| output[:message] == message }
          I18n.t('analysis.thead', message: message, tds: target_outputs.map { |target_output| I18n.t('analysis.td', filename_line_number: filename_line_number(target_output[:filename], target_output[:line_number], analyzer)) }.join )
        end
        { body: I18n.t('analysis.template', rbp_outputs: format_outputs.join, errors_count: outputs.count).gsub('"', '').to_s }.to_json
      else
        { body: "
          # Rails Best Practices
          ***Fixed***
          " }.to_json
      end
    issue_comment = pull.issue_comments.find_or_initialize_by(status: :analysis)
    if issue_comment.persisted?
      data = Github::Request.update_issue_comment(params, pull)
      issue_comment.update(
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

  def filename_line_number(filename, line_number, analyzer)
    filename.gsub("#{analyzer.app_name}", '') + ":#{line_number}"
  end
end
