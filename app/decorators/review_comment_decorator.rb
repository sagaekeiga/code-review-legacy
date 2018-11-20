class ReviewCommentDecorator < ApplicationDecorator
  delegate_all
  def avatar
    reviewer.present? ? reviewer.github_account.avatar_url : 'reviewee.jpg'
  end

  def nickname
    reviewer.present? ? reviewer.github_account.nickname : 'reviewee'
  end

  # 最後のリプライであればlastクラスを返す。lastクラスはステップラインを非表示にする。
  def is_last?(review_comment)
    object.id&.eql?(review_comment.replies.last&.id) ? 'last' : ''
  end

  def step_image
    has_unread_replies? ? 'warning.png' : 'checked.png'
  end
end
