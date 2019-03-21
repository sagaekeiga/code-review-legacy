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
    errors = analyzer.output
    params = outputs_to_json(errors)

    issue_comment = pull.issue_comments.find_or_initialize_by(status: :analysis)

    if issue_comment.persisted?
      update_issue_comment(params, pull, issue_comment)
    else
      create_issue_comment(params, pull, issue_comment)
    end
    Rails.logger.info data
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
