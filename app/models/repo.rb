# == Schema Information
#
# Table name: repos
#
#  id              :bigint(8)        not null, primary key
#  deleted_at      :datetime
#  full_name       :string
#  name            :string
#  private         :boolean
#  resource_type   :string
#  status          :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  installation_id :bigint(8)
#  remote_id       :integer
#  resource_id     :integer
#
# Indexes
#
#  index_repos_on_deleted_at  (deleted_at)
#

class Repo < ApplicationRecord
  acts_as_paranoid
  paginates_per 10
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  belongs_to :resource, polymorphic: true
  has_many :pulls, dependent: :destroy
  has_many :skillings, dependent: :destroy, as: :resource
  has_many :skills, through: :skillings
  # -------------------------------------------------------------------------------
  # Validations
  # -------------------------------------------------------------------------------
  validates :remote_id, presence: true, uniqueness: true
  validates :name, presence: true
  validates :full_name, presence: true, uniqueness: true
  validates :private, inclusion: { in: [true, false] }
  validates :installation_id, presence: true

  # -------------------------------------------------------------------------------
  # Enumerables
  # -------------------------------------------------------------------------------
  # 性別
  #
  # - hidden  : 非公開
  # - showing : 公開
  #
  enum status: {
    hidden:  1000,
    showing: 2000
  }

  # -------------------------------------------------------------------------------
  # Attributes
  # -------------------------------------------------------------------------------
  attribute :status, default: statuses[:hidden]
  attribute :private, default: false
  # -------------------------------------------------------------------------------
  # Scopes
  # -------------------------------------------------------------------------------
  scope :owned_by_orgs, lambda { |reviewee|
    where(resource_id: reviewee.orgs.owner.pluck(:id), resource_type: 'Org')
  }
  class << self
    #
    # リモートのレポジトリを保存する or リストアする
    #
    # @param [ActionController::Parameter] repositories_added_params addedなPOSTパラメータ
    #
    # @return [Boolean] 保存 or リストアに成功すればtrue、失敗すればfalseを返す
    #
    def fetch!(params)
      resource_type = params[:installation][:account][:type].eql?('User') ? 'Reviewee' : 'Org'
      resource = _set_resource_for_repo(params, resource_type)
      return true if resource.nil?
      repos =
        if params[:repositories_added].present?
          params[:repositories_added]
        else
          params[:repositories]
        end
      repos.each do |repository|
        begin
          ActiveRecord::Base.transaction do
            repository = ActiveSupport::HashWithIndifferentAccess.new(repository)
            repo = with_deleted.find_or_create_by(remote_id: repository[:id])
            repo.restore if repo&.deleted?
            repo.update_attributes!(
              _merge_params(
                resource_type,
                resource,
                repository,
                params
              )
            )
            repo.import_contents!
            Pull.fetch!(repo)
            Issue.fetch!(repo)
          end
          true
        rescue => e
          Rails.logger.error e
          Rails.logger.error e.backtrace.join("\n")
          false
        end
      end
    end

    # レビュワーのスキルに合致するPRを取得する
    def pulls_suitable_for reviewer
      repos = joins(:skillings).where(skillings: { skill_id: reviewer.skillings.pluck(:skill_id) })
      Pull.includes(:repo).request_reviewed.where(repo_id: repos&.pluck(:id))
    end

    private

    def _set_resource_for_repo(params, resource_type)
      resource =
        if resource_type.eql?('Reviewee')
          Reviewees::GithubAccount.find_by(owner_id: params[:installation][:account][:id]).reviewee
        else
          Org.find_by(remote_id: params[:installation][:account][:id])
        end
    end

    def _merge_params(resource_type, resource, repo_params, params)
      {
        resource_type: resource_type,
        resource_id: resource.id,
        name: repo_params[:name],
        full_name: repo_params[:full_name],
        private: repo_params[:private],
        installation_id: params[:installation][:id]
      }
    end
  end

  def import_wikis!(file_params, resource)
    ActiveRecord::Base.transaction do
      wikis.delete_all
      zipfile = file_params
      Zip::File.open(zipfile.path) do |zip|
        zip.each do |entry|
          next unless File.extname(entry.name).eql?('.md')
          @title = File.basename(entry.name).gsub('.md', '')
          ext = File.extname(entry.name)
          Tempfile.open([File.basename(entry.to_s), ext]) do |file|
            entry.extract(file.path) { true }
            body = file.read
            wiki = wikis.new(
              resource_type: resource.class.to_s,
              resource_id: resource.id,
              title: @title,
              body: body
            )
            wiki.save!
            file.close!
          end
        end
      end
    end
    true
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    false
  end


  def import_contents!
    ActiveRecord::Base.transaction do
      # リモートZIPファイルの作成
      zipfile = Tempfile.new('file')
      zipfile.binmode
      reviewee = set_resource_for_content
      remote_zip = Github::Request.github_exec_fetch_repo_zip!(self, reviewee.github_account)
      zipfile.write(remote_zip.body)
      zipfile.close
      # リモートZIPファイルの取り込み
      Zip::File.open(zipfile.path) do |zip|
        # トップディレクトリ
        zip.each_with_index do |entry, index|
          break unless index.eql?(0)
          zip.glob(entry.name + '*').each do |top_dir|
            next if Settings.contents.prohibited_folders.include?(File.basename(top_dir.to_s))
            file_type = _set_symbol_file_type(top_dir)
            @parent = Content.new(_content_params(top_dir, file_type, self))
            @parent.save
          end
        end
        # トップディレクトリの一個下のサブディレクリ
        self.contents.dir.each { |top_dir| _expand_and_create_contents(zip, top_dir, self) }
        loop do
          parents = self.contents.dir.select(&:is_sub_dir?)
          break if parents.blank?
          # サブディレクトリ・ファイルの取得
          parents.each { |parent| _expand_and_create_contents(zip, parent, self) }
        end
      end
    end
    true
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    false
  end

  def set_resource_for_content
    case resource_type
    when 'Reviewee'
      Reviewee.find(resource_id)
    when 'Org'
      org = Org.find(resource_id)
      org.owner
    end
  end

  def reviewee?(current_reviewee)
    resource_type.eql?('Reviewee') && resource_id.eql?(current_reviewee.id)
  end

  def reviewee_org?(current_reviewee)
    resource_type.eql?('Org') && current_reviewee.orgs.exists?(id: resource_id)
  end

  def membership?(current_reviewee)
    owner =
      case resource_type
      when 'Reviewee'
        Reviewee.find_by(id: resource_id)
      when 'Org'
        org = Org.find_by(id: resource_id)
        org.reviewee_orgs.owner
      end
    current_reviewee.owners.exists?(id: owner.id)
  end

  private

  def _content_params(dir_or_file, file_type, repo)
    {
      path: dir_or_file.name,
      name: File.basename(dir_or_file.to_s),
      content: _verify_content(file_type, dir_or_file),
      resource_type: repo.resource_type,
      resource_id: repo.resource_id,
      file_type: file_type,
      repo: repo
    }
  end

  def _content_tree_params(parent, child)
    {
      parent: parent,
      child: child
    }
  end

  def _expand_and_create_contents(zip, parent, repo)
    zip.glob(parent.path + '*').each do |dir_or_file|
      file_type = _set_symbol_file_type(dir_or_file)
      child = Content.new(_content_params(dir_or_file, file_type, repo))
      child.save
      content_tree = ContentTree.new(_content_tree_params(parent, child))
      content_tree.save
    end
  end

  def _set_symbol_file_type(dir_or_file)
    dir_or_file.ftype.eql?(:directory) ? :dir : :file
  end

  def _verify_content(file_type, dir_or_file)
    return nil if Settings.contents.prohibited_files.extnames.include?(File.extname(dir_or_file.name))
    file_type.eql?(:dir) ? nil : dir_or_file.get_input_stream.read
  end
end
