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
#  token           :string           not null
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

require 'rails_helper'

RSpec.describe Repo, type: :model do
  let(:repo_new) { reviewee.repos }
  let(:repo) { create(:repo, reviewee: reviewee) }
  let(:reviewee) { create(:reviewee) }
  let(:repositories_added_params) {
    [
      [
        ActionController::Parameters.new(
          id: id,
          name: name,
          full_name: full_name,
          private: true
        ).permit(:question_section_id, :body)
      ]
    ]
  }
  # リモートのレポジトリを保存する
  describe '#create_or_restore!' do
    # context 'レポジトリが空なら作成する' do
    #   let(:id) { repo.remote_id + 1 }
    #   let(:name) { repo.name + 'n' }
    #   let(:full_name) { repo.full_name + 'n' }
    #   subject {
    #     repo_new.create_or_restore!(repositories_added_params)
    #     Repo.count
    #   }
    #   it { is_expected.to eq 1 }
    # end

    context 'レポジトリがすでに存在すれば作成しない' do
    end

    context '論理削除されたレポジトリが存在すればリストアする' do
    end
  end
end
