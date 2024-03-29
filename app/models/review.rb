# == Schema Information
#
# Table name: reviews
#
#  id         :bigint(8)        not null, primary key
#  body       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  pull_id    :bigint(8)
#  remote_id  :bigint(8)
#  user_id    :bigint(8)
#
# Indexes
#
#  index_reviews_on_pull_id  (pull_id)
#  index_reviews_on_user_id  (user_id)
#

class Review < ApplicationRecord
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  belongs_to :user, counter_cache: true
  belongs_to :pull
  has_many :pull_tags, dependent: :destroy
  has_many :tags, through: :pull_tags
  has_many :review_requests, dependent: :destroy
  # -------------------------------------------------------------------------------
  # Validations
  # -------------------------------------------------------------------------------
  validates :remote_id, presence: true, uniqueness: true, on: %i(create)
  validates :body, presence: true
  # -------------------------------------------------------------------------------
  # Delegations
  # -------------------------------------------------------------------------------
  delegate :title, to: :pull
  delegate :number, to: :pull
  # -------------------------------------------------------------------------------
  # ClassMethods
  # -------------------------------------------------------------------------------
  class << self
    def fetch!(params)
      reviewer = Users::GithubAccount.find_by(owner_id: params[:review][:user][:id]).user
      pull = Pull.find_by(remote_id: params[:pull_request][:id])
      return if (reviewer.nil? || pull.nil?) || (reviewer == pull.user)

      review = Review.find_or_initialize_by(
        remote_id: params[:review][:id],
        user: reviewer,
        pull: pull
      )

      review.assign_attributes(
        body: params[:review][:body]
      )

      review.save

      return if ENV['SLACK_WEBHOOK_URL'].nil?

      notifier = Slack::Notifier.new ENV['SLACK_WEBHOOK_URL']
      attachments = {
        fallback: "This is article notifier attachment",
        title: review.title,
        text: "<a href='https://github.com/#{review.pull.full_name}/pull/#{review.number}'>https://github.com/#{review.pull.full_name}/pull/#{review.number}</a>",
        color: 'good'
      }
      notifier.post text: 'レビューがありました',  attachments: attachments

    end
  end
end
