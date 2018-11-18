# == Schema Information
#
# Table name: commits
#
#  id             :bigint(8)        not null, primary key
#  committed_date :string
#  committer_name :string
#  deleted_at     :datetime
#  message        :string
#  resource_type  :string
#  sha            :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  pull_id        :bigint(8)
#  resource_id    :integer
#
# Indexes
#
#  index_commits_on_deleted_at  (deleted_at)
#  index_commits_on_pull_id     (pull_id)
#
# Foreign Keys
#
#  fk_rails_...  (pull_id => pulls.id)
#

class Commit < ApplicationRecord
  acts_as_paranoid
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  belongs_to :resource, polymorphic: true
  belongs_to :pull
  has_many :changed_files, dependent: :destroy
  # -------------------------------------------------------------------------------
  # Validations
  # -------------------------------------------------------------------------------
  validates :pull_id, uniqueness: { scope: :sha }, on: %i(create)
  # -------------------------------------------------------------------------------
  # ClassMethods
  # -------------------------------------------------------------------------------
  def self.fetch!(pull)
    ActiveRecord::Base.transaction do
      res_commits = Github::Request.github_exec_fetch_commits!(pull)
      res_commits.each do |res_commit|
        update = true
        commit = pull.commits.with_deleted.find_or_initialize_by(
          sha: res_commit['sha'],
          resource_type: pull.repo.resource_type,
          resource_id: pull.repo.resource_id,
          committer_name: res_commit['commit']['committer']['name'],
          committed_date: res_commit['commit']['committer']['date'],
        )
        update = false unless commit.persisted?
        commit.restore if commit.deleted?
        commit.update_attributes!(message: res_commit['commit']['message'])
        next if update && commit.changed_files.present?
        ChangedFile.fetch!(commit)
        ChangedFile.fetch_diff!(pull)
      end
    end
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    fail I18n.t('views.error.failed_create_commit')
  end
end
