class Content
  include ActiveModel::Model
  include ActiveModel::Attributes
  include Draper::Decoratable

  attribute :name, :string
  attribute :path, :string
  attribute :content, :string
  attribute :type, :integer

  attr_accessor :data
  # -------------------------------------------------------------------------------
  # Enumerables
  # -------------------------------------------------------------------------------
  TYPE = {
    file: 1000,
    dir:  2000
  }.with_indifferent_access

  # -------------------------------------------------------------------------------
  # ClassMethods
  # -------------------------------------------------------------------------------
  class << self
    def types
      TYPE
    end

    #
    # API から取得したデータを元にインスタンスを生成する。
    # @param [Hash] data
    # @return [Content]
    #
    def load(data)
      new(convert_data(data)).tap do |content|
        content.data = data
      end
    end

    #
    # Github からContentを検索してインスタンスを返す。
    #
    # @param [Repo] repo レポジトリ
    # @param [String] path ファイルパス
    # @return [Content]
    # @raise [RuntimeError] 取得失敗時に発生。Cloudbeds からのエラーメッセージ
    #
    def find(repo:, path:)
      data = Github::Request.content(repo: repo, path: path)
      fail data if data.is_a?(String)
      load(data)
    end

    def initializes(contents:)
      dir_and_file_contents = []
      file_contents = []
      dir_contents = []
      contents.each do |content|
        sort_before_content = new(
          name: content[:name],
          path: content[:path],
          content: content[:content],
          type: content[:type].eql?('dir') ? :dir : :file
        )
        if sort_before_content.dir?
          dir_contents << sort_before_content
        else
          file_contents << sort_before_content
        end
      end
      dir_and_file_contents << dir_contents
      dir_and_file_contents << file_contents
      dir_and_file_contents.flatten!.reject(&:blank?)
    end

    #
    # Github API が返す Hash をモデル定義に沿ったものに変換する。
    #
    # @param [Hash] API から取得した Hash
    # @return [Hash] 変換後の Hash
    #
    def convert_data(data)
      new_data = {}

      %i(name path content type).each do |key|
        new_data[key] = data[key]
      end

      new_data
    end
  end

  TYPE.each do |key, value|
    define_method("#{key}?") { @type == value }
    define_method("#{key}!") { @type = value }
  end

  # -------------------------------------------------------------------------------
  # InstanceMethods
  # -------------------------------------------------------------------------------
  def type=(value = nil)
    if TYPE.has_key?(value) || value.blank?
      @type = TYPE[value]
    elsif TYPE.has_value?(value)
      @type = value
    else
      raise ArgumentError "'#{value}' is not a valid type"
    end
  end

  def type
    TYPE.key(@type)
  end
end