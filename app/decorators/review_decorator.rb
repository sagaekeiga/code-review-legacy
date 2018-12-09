class ReviewDecorator < ApplicationDecorator
  delegate_all
  def trimed_commit_id
    remote_id[0...10]
  end

  def step_image
    persisted? ? 'unchecked.png' : 'checked.png'
  end

  def path
    case event
    when 'pending'
      h.reviewers_pull_review_path(pull, object)
    when 'comment'
      h.reviewers_pull_review_replies_path(pull, object)
    end
  end

  # 審査を通過していればactiveクラスを返す
  def check_pass_review
    if approve? || comment?
      'complete'
    elsif controller.action_name.eql?('show')
      'active'
    else
      'disabled'
    end
  end

  # 作業中であれば「作業中」を返す。
  def check_progress
    remote_id.present? ? remote_id : I18n.t('reviewers.reviews.sidebars.working')
  end

  def check_complete_review
    persisted? && pull.completed? ? 'active' : ''
  end

  def check_new_page
    if review.persisted?
      'complete'
    elsif controller.action_name.eql?('new')
      'active'
    end
  end
end
