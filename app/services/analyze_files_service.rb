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
  end

  def rails_best_practices(pull:)
    pull.analysis = :rbp
    pull.create_check_runs
    analyzer = RailsBestPractices::Analyzer.new(ARGV.first, {}, pull: @pull)
    analyzer.analyze
    pull.checks = analyzer.output
    pull.update_check_runs
  end
end
