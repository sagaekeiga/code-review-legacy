class Pull::ChangedFileDecorator < ApplicationDecorator
  delegate_all

  # 言語をシンボルで返す
  def symbolized_lang
    case File.extname(filename)
    when '.rb', '.rake' then :ruby
    when '.cc', '.cp', '.cpp', '.cxx', '.c' then :c
    when '.py' then :python
    when '.js', '.coffee' then :javascript
    when '.java' then :java
    when '.html' then :html
    when '.php' then :php
    when '.sass', '.scss' then :sass
    when '.css' then :css
    when '.yml' then :yaml
    when '.haml' then :html
    else
      :html
    end
  end

  # シンタックスハイライトで返す
  def coderay(line)
    CodeRay.scan(line, symbolized_lang).div.html_safe
  end

  # レビューコメントがあるかどうかを返す
  def present_review_comment?(index)
    ReviewComment.find_by(sha: sha, position: index, path: filename).present?
  end

  # レビューコメントのIDを返す
  def review_comment_id(index)
    ReviewComment.find_by(sha: sha, position: index, path: filename)&.id
  end

  # レビューコメントを返す
  def review_comment_body(index)
    ReviewComment.find_by(sha: sha, position: index, path: filename)&.body
  end

  # レビューコメントのパスを返す
  def review_comment_path(index)
    ReviewComment.find_by(sha: sha, position: index, path: filename)&.path
  end

  # レビューコメントのポジションを返す
  def review_comment_position(index)
    ReviewComment.find_by(sha: sha, position: index, path: filename)&.position
  end

  #
  # 追加行の行数を返す
  # @param [String] 展開されている行
  # @param [Integer] セクションの連番 ex. ['@@ -1,2 +1,2 @@', '@@ -3,4 +3,4 @@', ''@@ -5,6 +5,6 @@']
  # @param [Integer] 展開されている行の連番
  # @return [Integer]
  #
  def additional_line_number(line:, section_num:, line_num:)
    return '' if line.start_with?('-')
    # Ex. [1, 2]
    line_numbers = target_section(section_num).match(/\+.*? /).to_s.strip.delete('+').split(',')

    start_line_number = line_numbers.first.to_i
    end_line_number = line_numbers.last.to_i + (start_line_number - 1)

    lines_except_deleted_rows = line_num - deleted_rows(section_num: section_num, line_num: line_num)

    (start_line_number..end_line_number).map(&:to_i)[lines_except_deleted_rows]
  end

  #
  # 削除行の行数を返す
  # @param [String] 展開されている行
  # @param [Integer] セクションの連番 ex. ['@@ -1,2 +1,2 @@', '@@ -3,4 +3,4 @@', '@@ -5,6 +5,6 @@']
  # @param [Integer] 展開されている行の連番
  # @return [Integer]
  #
  def deletional_line_number(line:, section_num:, line_num:)
    return '' if line.start_with?('+')
    # Ex. [1, 2]
    line_numbers = target_section(section_num).match(/-.*? /).to_s.strip.delete('-').split(',')

    start_line_number = line_numbers.first.to_i
    end_line_number = line_numbers.last.to_i + start_line_number - 1

    lines_except_added_rows = line_num - added_rows(section_num: section_num, line_num: line_num)

    (start_line_number..end_line_number).map(&:to_i)[lines_except_added_rows]
  end

  #
  # 削除された行数を返す
  # @param [Integer] section_num セクションの連番
  # @param [Integer] line_num 現在の行数
  # @return [Intger]
  #
  def deleted_rows(section_num:, line_num:)
    deletional_line_count = 0
    patch.split(/@@.*@@.*\n/).reject(&:empty?)[section_num].each_line.with_index(1) do |line, index|
      deletional_line_count += 1 if line.start_with?('-')
      return deletional_line_count if line_num == index
    end
  end

  #
  # 追加された行数を返す
  # @param [Integer] section_num セクションの連番
  # @param [Integer] line_num 現在の行数
  # @return [Intger]
  #
  def added_rows(section_num:, line_num:)
    additional_line_count = 0
    patch.split(/@@.*@@.*\n/).reject(&:empty?)[section_num].each_line.with_index do |line, index|
      additional_line_count += 1 if line.start_with?('+')
      return additional_line_count if line_num == index
    end
  end

  #
  # 該当するセクションを返す
  # @param [Integer] セクションの連番
  # @return [String]
  #
  def target_section(section_num)
    patch.scan(/@@.*@@/)[section_num]
  end
end
