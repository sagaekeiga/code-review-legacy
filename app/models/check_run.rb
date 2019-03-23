class CheckRun
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :id,                  :integer
  attribute :name,                :string
  attribute :installation_id,     :integer
  attribute :repo_full_name,      :string
  attribute :check_run_id,        :integer
  attribute :head_sha,            :integer
  attribute :status,              :string
  attribute :conclusion,          :string
  attribute :completed_at,        :datetime
  attribute :output,              :hash
  attribute :annotations,         :array
  attribute :analysis_name,       :string

  attr_accessor :checks

  class << self
    def initialize(data = {})
      self.checks = data[:checks]
      self.name = "openci: #{data[:analysis_name]}"
      self.head_sha = data[:head_sha]
      self.status = data[:status].to_s
      self.analysis_name = convert_analysis_name(data)
      self.conclusion = convert_conclusion(data)
      self.output = convert_output(data)
      self.completed_at = convert_completed_at(data)
    end

    private

    #
    # 静的解析名を返す
    # @param [Symbol] analysis 静的解析名
    # @return [String]
    #
    def convert_analysis_name(data)
      case data[:analysis]
      when :rbp then 'rails_best_practices'
      end
    end

    def convert_conclusion(data)
      has_errors?(data) ? 'failure' : 'success'
    end

    #
    # 解析結果を返す
    # @return [Hash]
    #
    def convert_output(data)
      {
        title: convert_title(data),
        summary: summary(data),
        annotations: annotations(data[:checks])
      }
    end

    #
    # detailページのタイトルを返す
    # @return [String]
    #
    def convert_title(data)
      has_errors?(data) ? 'Your tests failed on OpenCI' : 'Your tests passed on OpenCI!'
    end

    #
    # エラー（注意）を配列で返す
    # @return [Array<Check>]
    #
    def has_errors?(data)
      data[:checks].present?
    end

    #
    # エラー（注意）を配列で返す
    # @return [Array<Check>]
    #
    def annotations=(checks)
      checks.map(&:attributes)
    end

    def convert_completed_at
      case status.to_s
      when 'completed' then Time.zone.now
      else
        nil
      end
    end

    #
    # detailページの説明文を返す
    # @return [String]
    #
    def summary(data)
      if has_errors?(data)
        failure_summary_by(data[:analysis])
      else
        success_summary_by(data[:analysis])
      end
    end

    def failure_summary_by(analysis)
      case analysis
      when :rbp
        "Please go to https://rails-bestpractices.com to see more useful Rails Best Practices.<br><br>Found #{checks.count} warnings."
      end
    end

    def success_summary_by(analysis)
      case analysis
      when :rbp
        "Please go to https://rails-bestpractices.com to see more useful Rails Best Practices.<br><br>No warning found. Cool!"
      end
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
  # バリデーションをスキップしてデータを更新する。
  # 失敗時にはエラーがセットされる。
  #
  # @return [Boolean] 成否
  #
  def update
    result = Github::Request.update_check_runs(attributes: attributes)
    if result.dig(:message)
      Rails.logger.error "[Failure][Update][CheckRuns] #{result}"
      false
    else
      Rails.logger.info "[Success][Update][CheckRuns] #{result}"
      true
    end
  end

  #
  # 新規作成の処理を行う。
  # 成功すると id がセットされる。
  #
  # @return [Boolean] 成否
  #
  def insert
    return if persisted?

    result = Github::Request.create_check_runs(attributes: attributes)
    if result.dig(:message)
      Rails.logger.error "[Failure][Create][CheckRuns] #{result}"
      return false
    else
      self.check_run_id = data[:id]
      Rails.logger.info "[Success][Create][CheckRuns] #{result}"
    end
    true
  end
end