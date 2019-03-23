class CheckRun
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :id,                  :integer
  attribute :name,                :string
  attribute :installation_id,     :integer
  attribute :repo_full_name,      :string
  attribute :head_sha,            :string
  attribute :status,              :string
  attribute :conclusion,          :string
  attribute :completed_at,        :datetime
  attribute :analysis,            :string
  attribute :analysis_name,       :string

  attr_accessor :checks, :output, :annotations

  class << self
    def initialize(data = {})
      self.id = data[:check_run_id]
      self.checks = data[:checks]
      self.analysis = data[:analysis]
      self.installation_id = data[:installation_id]
      self.repo_full_name = data[:repo_full_name]
      self.head_sha = data[:head_sha]
      self.status = data[:status].to_s
    end
  end

  # -------------------------------------------------------------------------------
  # InstanceMethods
  # -------------------------------------------------------------------------------
  #
  # @return [Boolean] 成否
  #
  def save
    if persisted?
      update
    else
      insert
    end
  end

  #
  # 永続化済みかどうか
  # @return [Boolean]
  #
  def persisted?
    id.present?
  end

  private

  #
  # 新規作成の処理を行う。
  # 成功すると id がセットされる。
  #
  # @return [Boolean] 成否
  #
  def insert
    return if persisted?

    load_for_insert
    output = {
      title: 'The OpenCI analysis is in progress.',
      summary: 'The OpenCI analysis is in progress.'
    }

    result = Github::Request.create_check_runs(attributes: attributes.merge(output: output).symbolize_keys)

    if result.dig(:message)
      Rails.logger.error "[Failure][Create][CheckRuns] #{result}"
      return false
    else
      self.id = result[:id]
      Rails.logger.info "[Success][Create][CheckRuns] #{result}"
    end
    self.id
  end

  #
  # バリデーションをスキップしてデータを更新する。
  # 失敗時にはエラーがセットされる。
  #
  # @return [Boolean] 成否
  #
  def update

    load_for_update
    output = convert_output

    result = Github::Request.update_check_runs(attributes: attributes.merge(output: output).symbolize_keys)

    if result.dig(:message)
      Rails.logger.error "[Failure][Update][CheckRuns] #{result}"
      false
    else
      Rails.logger.info "[Success][Update][CheckRuns] #{result}"
      true
    end
  end

  def load_for_insert
    assign_attributes(
      analysis_name: convert_analysis_name,
      name: "openci: #{convert_analysis_name}"
    )
  end

  def load_for_update
    assign_attributes(
      name: "openci: #{convert_analysis_name}",
      conclusion: convert_conclusion,
      completed_at: Time.zone.now,
      output: {
        title: convert_title,
        summary: summary,
        annotations: convert_annotations
      }
    )
  end

  #
  # 静的解析名を返す
  # @param [Symbol] analysis 静的解析名
  # @return [String]
  #
  def convert_analysis_name
    case self.analysis
    when 'rbp' then 'rails_best_practices'
    end
  end

  def convert_conclusion
    has_errors? ? 'failure' : 'success'
  end

  #
  # 解析結果を返す
  # @return [Hash]
  #
  def convert_output
    {
      title: convert_title,
      summary: summary,
      annotations: convert_annotations
    }
  end

  #
  # detailページのタイトルを返す
  # @return [String]
  #
  def convert_title
    has_errors? ? 'Your tests failed on OpenCI' : 'Your tests passed on OpenCI!'
  end

  #
  # エラー（注意）を配列で返す
  # @return [Array<Check>]
  #
  def has_errors?
    checks.present?
  end

  #
  # エラー（注意）を配列で返す
  # @return [Array<Check>]
  #
  def convert_annotations
    Rails.logger.debug "convert_annotations"
    checks.map(&:attributes)
  end

  #
  # detailページの説明文を返す
  # @return [String]
  #
  def summary
    if has_errors?
      failure_summary_by
    else
      success_summary_by
    end
  end

  def failure_summary_by
    case analysis
    when 'rbp'
      "Please go to https://rails-bestpractices.com to see more useful Rails Best Practices.<br><br>Found #{checks.count} warnings."
    end
  end

  def success_summary_by
    case analysis
    when 'rbp'
      "Please go to https://rails-bestpractices.com to see more useful Rails Best Practices.<br><br>No warning found. Cool!"
    end
  end
end