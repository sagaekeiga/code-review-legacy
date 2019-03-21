class RailsBestPractices::Error < RailsBestPractice
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :filename,    :string
  attribute :line_number,    :string
  attribute :message,    :string

  class << self
    def initialize(data = {})
      self.filename = data[:filename]
      self.line_number = data[:line_number]
      self.message = data[:message]
    end

    #
    # テーブル一覧を返す
    # @param [Array<RailsBestPractices::Error>] data RailsBestPractices::Error 配列
    # @return [Array<Strings>]
    #
    def tables(data)
      uniq_message_errors(data).map do |uniq_message_error|
        uniq_message_error.table(data)
      end
    end

    #
    # 一意なメッセージ一覧の error を返す
    # @param [Array<RailsBestPractices::Error>] data RailsBestPractices::Error 配列
    # @return [Array<RailsBestPractices::Error>]
    #
    def uniq_message_errors(data)
      data.map(&:message).uniq.map do |message|
        new({ message: message })
      end
    end

    #
    # table data に整形した error 一覧を文字列で返す
    # @param [Array<RailsBestPractices::Error>] data RailsBestPractices::Error 配列
    # @return [String]
    #
    def table_datas(data)
      data.map(&:table_data).join
    end
  end

  #
  # エラーメッセージに該当するパス一覧 table で返す
  # @param [Array<RailsBestPractices::Error>] data RailsBestPractices::Error 配列
  # @return [String]
  #
  def table(data)
    target_errors = data.select { |error| error.is_same?(message) }
    I18n.t('analysis.table', message: message, table_datas: RailsBestPractices::Error.table_datas(target_errors) )
  end

  #
  # 該当の ファイルパス + 行数 を返す
  # @return [String]
  #
  def point
    "#{filename}:#{line_number}"
  end

  #
  # table data に整形した error を返す
  # @return [String]
  #
  def table_data
    I18n.t('analysis.table_data', point: point)
  end

  #
  # 同じエラーメッセージかどうかを返す
  # @params [String] message エラーメッセージ
  # @return [Boolean]
  #
  def is_same?(msg)
    message == msg
  end
end