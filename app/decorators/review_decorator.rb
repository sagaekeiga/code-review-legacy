class ReviewDecorator < ApplicationDecorator
  delegate_all
  def trimed_commit_id
    remote_id[0...10]
  end

  def step_image
    persisted? ? 'unchecked.png' : 'checked.png'
  end

  # 審査を通過していればactiveクラスを返す
  def check_pass_review
    (approve? || comment?) ? 'active' : ''
  end

  # 作業中であれば「作業中」を返す。
  def check_progress
    remote_id.present? ? remote_id : I18n.t('reviewers.reviews.sidebars.working')
  end
end
