class ReviewCommentDecorator < ApplicationDecorator
  delegate_all
  def avatar
    reviewer.present? ? reviewer.github_account.avatar_url : 'reviewee.jpg'
  end

  def nickname
    reviewer.present? ? reviewer.github_account.nickname : 'reviewee'
  end

  # 最後のリプライであればlastクラスを返す。lastクラスはステップラインを非表示にする。
  def last?(review_comment)
    object.id&.eql?(replies.last&.id) ? 'last' : ''
  end

  def step_image
    has_unread_replies? ? 'warning.png' : 'checked.png'
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

  def status
    review.present? ? '審査中' : '下書き'
  end
end
