# == Schema Information
#
# Table name: reviews
#
#  id          :bigint(8)        not null, primary key
#  body        :text
#  deleted_at  :datetime
#  event       :integer
#  reason      :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  commit_id   :string
#  pull_id     :bigint(8)
#  remote_id   :bigint(8)
#  reviewer_id :bigint(8)
#
# Indexes
#
#  index_reviews_on_deleted_at   (deleted_at)
#  index_reviews_on_pull_id      (pull_id)
#  index_reviews_on_reviewer_id  (reviewer_id)
#
# Foreign Keys
#
#  fk_rails_...  (pull_id => pulls.id)
#  fk_rails_...  (reviewer_id => reviewers.id)
#

class Review < ApplicationRecord
  acts_as_paranoid
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  belongs_to :reviewer, optional: true
  belongs_to :pull
  has_many :review_comments, dependent: :destroy

  # -------------------------------------------------------------------------------
  # Enumerables
  # -------------------------------------------------------------------------------
  # イベント
  #
  # - pending         : 審査中
  # - comment         : コメント
  # - request_changes : 修正を要求
  # - approve         : 承認
  # - refused         : 非承認
  #
  enum event: {
    pending:         1000,
    comment:         2000,
    request_changes: 3000,
    approve:         4000,
    refused:         5000
  }

  # -------------------------------------------------------------------------------
  # Attributes
  # -------------------------------------------------------------------------------
  attribute :event, default: events[:pending]

  # -------------------------------------------------------------------------------
  # Validations
  # -------------------------------------------------------------------------------
  validates :remote_id, uniqueness: true, allow_nil: true

  # レビューはidが可変なので、commit_idを識別子にする
  def self.update_by_commit_id!(params)
    ActiveRecord::Base.transaction do
      pull = Pull.find_by(
        remote_id: params[:pull_request][:id],
        number:    params[:pull_request][:number]
      )
      review = pull.reviews.find_by(body: params[:review][:body])
      # レビューの内容を変えた場合は、commit_idから取得
      review = pull.reviews.find_or_initialize_by(commit_id: params[:review][:commit_id]) if review.nil?
      review.update_attributes!(
        remote_id: params[:review][:id],
        commit_id: params[:review][:commit_id]
      )
      repo = Repo.find_by(name: params[:repository][:name])
    end
    true
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    false
  end

  #
  # リモートに送るレビューデータの作成・レビューコメントの更新をする
  #
  def self.ready_to_review!(pull, param_body)
    review = new(
      pull: pull,
      body: param_body,
      event: :pending
    )
    review.save!
    review_comments = review.reviewer.review_comments.pending.order(:created_at).where(changed_file: pull.changed_files)
    review_comments.each do |review_comment|
      review_comment.review = review
      review_comment.reviewed!
      review_comment.save!
    end
    review
  end

  #
  # コメントを取得する
  #
  def self.fetch_issue_comments!(params)
    ActiveRecord::Base.transaction do
      return false if params[:sender][:type].eql?('Bot')
      repo = Repo.find_by(name: params[:repository][:name])
      return false unless repo
      # ① 該当するPRを取得
      pull = repo.pulls.find_by(number: params[:issue][:number])
      # ② ①がなければfalseを返す
      return false unless pull
      # ③ ①があればBodyを取得し作成
      @review = pull.reviews.create!(
        remote_id: params[:comment][:id],
        body: params[:comment][:body],
        event: :issue_comment
      )
    end
    ReviewerMailer.issue_comment(@review).deliver_later
    true
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    false
  end

  #
  # リモートのPRにレビューする
  #
  def github_exec_review!
    ActiveRecord::Base.transaction do
      request_body = { body: body, event: 'COMMENT', comments: [] }

      review_comments.where.not(reviewer: nil).pending.each do |review_comment|
        comment = {
          path: review_comment.path,
          position: review_comment.position.to_i,
          body: review_comment.body
        }
        request_body[:comments] << comment
      end

      request_params = request_body.to_json
      res = Github::Request.github_exec_review!(request_params, pull)

      fail res.body unless res.code == Settings.api.success.status.code
      review_comments.where.not(reviewer: nil).pending.each(&:reviewed!).each(&:completed!)
      comment!
      pull.reviewed!
    end
    true
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    false
  end

  #
  # リモートのISSUEまたはPRにレビューする
  #
  def github_exec_issue_comment!
    ActiveRecord::Base.transaction do
      body = { 'body': self.body }
      res = Github::Request.github_exec_issue_comment!(body.to_json, pull)
      fail res.body unless res.code == Settings.api.created.status.code
      save!
    end
    true
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    false
  end
end
