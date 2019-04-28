class ReviewCommentDecorator < ApplicationDecorator
  delegate_all
  # シンタックスハイライトで返す
  def coderay(line)
    CodeRay.scan(line, symbolized_lang).div.html_safe
  end

  # 言語をシンボルで返す
  def symbolized_lang
    case File.extname(path)
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

  def avatar
    reviewer.present? ? reviewer.github_account.avatar_url : 'reviewee.jpg'
  end

  def nickname
    reviewer.present? ? reviewer.github_account.nickname : 'reviewee'
  end

  # 最後のリプライであればlastクラスを返す。lastクラスはステップラインを非表示にする。
  def last?(review_comment)
    object.id&.eql?(review_comment.replies.last&.id) ? 'last' : ''
  end

  def status
    review.present? ? '審査中' : '下書き'
  end
end
