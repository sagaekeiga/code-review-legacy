class PullDecorator < ApplicationDecorator
  delegate_all
  # GitHub上のプルリクエストへのリンクを返す
  def remote_url
    Settings.github.web_domain + object.repo&.full_name + '/pull/' + object.number&.to_s
  end

  # レビュイーページのステータスを返す
  def status_title_for_reviewee
    if object.completed?
      I18n.t('views.status.completed')
    else
      I18n.t('views.status.pending')
    end
  end

  def back_path
    h.file_reviewers_pull_reviews_path(object)
  end

  def replies_path(id_param)
    id_param ? h.reviewers_pull_review_replies_path(pull, review_id: id_param) : '#'
  end

  def check_view_check
    if reviewer_pulls.present?
      'complete'
    elsif controller.action_name.eql?('view_check')
      'active'
    end
  end

  def check_replies
    if completed?
      'complete'
    elsif controller.action_name.eql?('index')
      'active'
    else
      'disabled'
    end
  end
end
