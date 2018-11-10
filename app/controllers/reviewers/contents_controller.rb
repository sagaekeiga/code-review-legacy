class Reviewers::ContentsController < Reviewers::BaseController
  before_action :set_repo, only: %i(index show)
  before_action :set_content, only: %i(show)
  skip_before_action *%i(verify_authenticity_token authenticate_reviewer!), only: %i(search)

  def index
    @dir_or_files = @repo.contents.top
    @readme = @repo.contents.find_by(name: 'README.md')
  end

  def show
    @dir_or_files = @content.children.sub(@content).decorate
  end

  # @FIXME デコードされた文字列で検索しているせいか適合率が低い
  def search
    repo = Repo.find(params[:repo_id])
    regexp = /#{params[:keyword]}/
    contents = repo.contents.where('content LIKE ?', "%#{Base64.encode64(params[:keyword])}%").pluck(:id, :path, :content) if params[:keyword].present?
    return render json: { message: '該当するファイルはありません' } if contents.blank?
    contents.each { |content| content[2] = Base64.decode64(content[2]).force_encoding('UTF-8') }
    contents.each do |content|
      # content #=> [id, path, content]
      next if content[2].nil?
      lines = content[2]
      content[2] = []
      lines.each_line do |line|
        content[2] << line if line =~ regexp
      end
    end
    render json: { contents: contents, repo_id: repo.id }
  end

  private

  def set_repo
    @repo = Repo.find(params[:repo_id]).decorate
  end

  def set_content
    @content = Content.find(params[:id])
  end
end
