class Pull::Commit
  include ActiveModel::Model
  include ActiveModel::Attributes
  include Draper::Decoratable

  attr_accessor :data, :filename, :patch, :content, :pull_id
  attr_accessor :data, :sha, :committer_name, :message, :committed_date

  #
  # @param [Hash] data
  #
  def initialize(data = {})
    self.data = data
    self.sha = data[:sha]
    self.committer_name = data[:commit][:committer][:name]
    self.message = data[:commit][:message]
    self.committed_date = data[:commit][:committer][:date]
  end

  #
  # コミットに紐付く差分ファイルを返す
  # @return [Array<ChangedFile>]
  #
  def file_changes
    data[:files].map do |file|
      ChangedFile.new(file)
    end
  end
end