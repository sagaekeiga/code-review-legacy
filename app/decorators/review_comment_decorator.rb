class ReviewCommentDecorator < ApplicationDecorator
  delegate_all
  def avatar
    if reviewer
      reviewer.github_account.avatar_url
    else
      'reviewee.jpg'
    end
  end

  def nickname
    if reviewer
      reviewer.github_account.nickname
    else
      'reviewee'
    end
  end

  def is_last?(review_comment)
    object.id&.eql?(review_comment.replies.last&.id) ? 'last' : ''
  end
end
