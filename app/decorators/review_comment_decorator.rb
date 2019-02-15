class ReviewCommentDecorator < ApplicationDecorator
  delegate_all
  def avatar
    reviewee? ? 'reviewee.jpg' : reviewer.github_account.avatar_url
  end

  def nickname
    reviewee? ? 'reviewee' : reviewer.github_account.nickname
  end

  # 最後のリプライであればlastクラスを返す。lastクラスはステップラインを非表示にする。
  def last?(review_comment)
    object.id&.eql?(review_comment.replies.last&.id) ? 'last' : ''
  end

  def step_image
    has_unread_replies? ? 'warning.png' : 'checked.png'
  end

  def set_read_message
    if has_unread_replies?
      content_tag(:span, (I18n.t 'reviewers.reviews.replies.unread_messages', message_count: count_unread_replies), class: 'unread')
    else
      content_tag(:span, (I18n.t 'reviewers.reviews.replies.read_messages'), class: 'read')
    end
  end

  def set_active
    has_unread_replies? ? 'active' : ''
  end

  def set_hidden(method_type)
    case method_type
    when :unread_replies
      has_unread_replies? ? '' : 'hidden'
    when :replies
      replies.present? ? '' : 'hidden'
    end
  end

  def set_unread
    has_unread_replies? ? 'unread' : ''
  end
end
