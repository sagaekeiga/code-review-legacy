class AnalyzeFilesService
  private_class_method :new

  def self.call(params:)
    pull = Pull.find_by(remote_id: params[:github_app][:pull_request][:id])
    return unless pull
    pull.head_sha = params[:github_app][:pull_request][:head][:sha]
    new(pull: pull).send(:call) if pull.repo_analysis
  end

  private

  def initialize(pull:)
    @pull = pull
  end

  def call
    @pull.create_check_runs
    rails_best_practices pull: @pull if @pull.has_rbp?
  end

  def rails_best_practices(pull:)
    analyzer = RailsBestPractices::Analyzer.new(ARGV.first, {}, pull: @pull)
    analyzer.analyze
    errors = analyzer.output
    params = outputs_to_json(errors)

    pull.checked_error = errors.present? ? true : false

    issue_comment = pull.issue_comments.find_or_initialize_by(status: :analysis)

    if issue_comment.persisted?
      update_issue_comment(params, pull, issue_comment)
    else
      create_issue_comment(params, pull, issue_comment)
    end
    pull.update_check_runs
  end

  #
  # 静的解析の結果コメントを作成する
  # @param [String] params コメント内容のJSON
  # @param [Pull] pull プルリクエスト
  # @param [IssueComment] issue_comment 静的解析の結果コメント
  #
  def create_issue_comment(params, pull, issue_comment)
    data = Github::Request.issue_comment(params, pull)
    issue_comment.assign_attributes(
      remote_id: data[:id],
      body: data[:body]
    )
    issue_comment.save
    Rails.logger.info "[Success][Create][Analysis] #{data}"
  end

  #
  # 静的解析の結果コメントを更新する
  # @param [String] params コメント内容のJSON
  # @param [Pull] pull プルリクエスト
  # @param [IssueComment] issue_comment 静的解析の結果コメント
  #
  def update_issue_comment(params, pull, issue_comment)
    data = Github::Request.update_issue_comment(params, pull)
    issue_comment.update(
      body: data[:body]
    )
    Rails.logger.info "[Success][Update][Analysis] #{data}"
  end

  #
  # 解析結果をJSONにして返す
  # @param [Array] outputs 解析結果
  # @return [String]
  #
  def outputs_to_json(errors)
    body =
      if errors.present?
        tables(errors)
      else
        I18n.t('analysis.fixed')
      end
    { body: body.delete('"').to_s }.to_json
  end

  #
  # 解析結果をコメント用（Markdown対応）に整形した文字列を返す
  # @param [Array] errors 解析結果
  # @return [String]
  #
  def tables(errors)
    tables = RailsBestPractices::Error.tables(errors)
    I18n.t('analysis.template', tables: tables.join, errors_count: errors.count)
  end
end
