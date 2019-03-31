class AnalyzeFilesService
  private_class_method :new

  def self.call(params:)
    pull = Pull.find_by(remote_id: params[:github_app][:pull_request][:id])
    return unless pull
    pull.head_sha = params[:github_app][:pull_request][:head][:sha]
    new(pull: pull).send(:call)
  end

  private

  def initialize(pull:)
    @pull = pull
  end

  def call
    rails_best_practices pull: @pull if @pull.has_rbp?
    rubocop pull: @pull if @pull.has_rubocop?
  end

  def rails_best_practices(pull:)
    Rails.logger.info '[Rails Best Practices][Analyze] Start'
    pull.analysis = :rbp
    check_run_id = pull.create_check_runs
    analyzer = RailsBestPractices::Analyzer.new(ARGV.first, {}, pull: @pull)
    analyzer.analyze
    pull.checks = analyzer.output
    pull.update_check_runs(check_run_id)
    Rails.logger.info '[Rails Best Practices][Analyze] Done'
  end

  def rubocop(pull:)
    Rails.logger.info '[Rubocop][Analyze] Start'
    pull.analysis = :rubocop
    check_run_id = pull.create_check_runs
    pull.checks = pull.run_rubocop
    pull.update_check_runs(check_run_id)
    Rails.logger.info '[Rubocop][Analyze] Done'
  end
end