require 'github/request.rb'
class Reviewers::ContentsController < Reviewers::BaseController
  before_action :set_repo, only: %i(index)

  def index
    if params[:keyword].present?
      res = Github::Request.github_exec_search_contents_scope_repo!(@repo, params[:keyword])
      res = ActiveSupport::HashWithIndifferentAccess.new(res)
      total_count = res[:total_count]
      names, paths, = [], []
      highlight_contents = []
      text = []
      res[:items].each do |item|
        item = ActiveSupport::HashWithIndifferentAccess.new(item)
        names << item[:name]
        paths << item[:path]
        @highlight_content = []
        item[:text_matches].each do |text_match|
          @content = []
          text_match = ActiveSupport::HashWithIndifferentAccess.new(text_match)

          # Matches
          matches = text_match[:matches]
          matches = ActiveSupport::HashWithIndifferentAccess.new(matches.first)
          text << matches[:text]

          # Highlight Contents
          fragment = text_match[:fragment]
          fragment.each_line do |line|
            line = line.gsub(' ', '&nbsp;')
            line = line.gsub(/[<]/, "&lt;")
            line = line.gsub(/[>]/, "&gt;")
            line = line.gsub(text.first, "<span class='text'>#{text.first}</span>")
            @content << line
          end
          @content.map! { |e| e ? e : '' }

          @highlight_content << @content
        end
        highlight_contents << @highlight_content
      end
      render json: {
        total_count: total_count,
        names: names,
        paths: paths,
        highlight_contents: highlight_contents,
        text: text
      }
    end
  end

  private

  def set_repo
    @repo = current_reviewer.repos.friendly.find(params[:repo_id]).decorate
  end
end
