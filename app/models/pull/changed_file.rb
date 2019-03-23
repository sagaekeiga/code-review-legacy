class Pull::ChangedFile
  include ActiveModel::Model
  include ActiveModel::Attributes
  include Draper::Decoratable

  attr_accessor :data, :sha, :filename, :patch, :content, :pull_id, :contents_url, :installation_id

  #
  # @param [Hash] data
  #
  def initialize(data = {})
    self.data = data
    self.installation_id = data[:installation_id]
    self.sha = data[:sha]
    self.filename = data[:filename]
    self.patch = data[:patch]
    self.content = data[:content]
    self.contents_url = data[:contents_url]
  end

  #
  # 差分ファイルの行にされたコメントを返す
  # @return <ReviewComment>
  #
  def find_review_comment_by(position:, reviewer:)
    ReviewComment.find_by(
      sha: sha,
      position: position,
      reviewer: reviewer,
      status: :pending
    )
  end

  #
  # 差分ファイルの全コードを返す
  # @return [String]
  #
  def content
    data = Github::Request.ref_content(url: contents_url, installation_id: installation_id)
    data[:content]
  end

  #
  # 差分ファイルにコメントが存在し、
  # そのコメントをしたレビュアーと現在のレビュアーが一致するかどうかを返す
  #
  # @param [Integer] index
  # @param [Reviewer] reviewer
  #
  # @return [Boolean]
  #
  def reviewer?(index, reviewer)
    ReviewComment.find_by(position: index, sha: sha, path: filename)&.reviewer&.present?
  end
end