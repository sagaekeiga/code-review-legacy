class Issue
  include ActiveModel::Model
  include ActiveModel::Attributes
  include Draper::Decoratable

  attribute :number, :integer
  attribute :title, :string
  attribute :body, :string

  attr_accessor :data
  # -------------------------------------------------------------------------------
  # ClassMethods
  # -------------------------------------------------------------------------------
  class << self
    #
    # Issueの場合は、issue_numberをidとする
    #
    # @param [Repo] repo レポジトリ
    # @param [Integer] id Issue ナンバー
    #
    # @return [Issue]
    #
    def find_by(repo:, id:)
      data = Github::Request.issue_by_number(repo, id)
      return nil if data.is_a?(String)
      load(data)
    end

    #
    # API から取得したデータを元にインスタンスを生成する。
    # @param [Hash] data
    # @return [Content]
    #
    def load(data)
      new(convert_data(data)).tap do |issue|
        issue.data = data
      end
    end

    #
    # Github API が返す Hash をモデル定義に沿ったものに変換する。
    #
    # @param [Hash] API から取得した Hash
    # @return [Hash] 変換後の Hash
    #
    def convert_data(data)
      new_data = {}

      %i(number title body).each do |key|
        new_data[key] = data[key]
      end

      new_data
    end
  end
end