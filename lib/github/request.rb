module Github
  class Request
    include HTTParty

    class << self
      # POST レビュー送信
      def github_exec_review!(params, pull)
        _post sub_url(:review, pull), pull.repo.installation_id, :review, params
      end

      # POST リプライ送信
      def github_exec_review_comment!(params, pull)
        _post sub_url(:review_comment, pull), pull.repo.installation_id, :review_comment, params
      end

      # GET レポジトリファイルの取得
      def github_exec_fetch_repo_contents!(repo, path = '')
        _get "repos/#{repo.full_name}/contents/#{path}", repo.installation_id, :content
      end

      # GET 差分ファイルの内容
      def github_exec_fetch_content_by_cf!(repo, sub_url)
        _get sub_url, repo.installation_id, :content
      end

      def github_exec_fetch_changed_file_content!(repo, content_url)
        headers = {
          'User-Agent': 'PushRequest',
          'Authorization': "token #{get_access_token(repo.installation_id)}",
          'Accept': set_accept(:content)
        }

        res = get content_url, headers: headers

        unless res.code == success_code(:content)
          logger.error "[Github][#{event}] responseCode => #{res.code}"
          logger.error "[Github][#{event}] responseMessage => #{res.message}"
          logger.error "[Github][#{event}] subUrl => #{sub_url}"
        end
        res
      end

      # GET プルリクエスト取得
      def github_exec_fetch_pulls!(repo)
        _get sub_url_for(repo, :pull), repo.installation_id, :pull
      end

      # GET ISSUE取得
      def github_exec_fetch_issues!(repo)
        _get sub_url_for(repo, :issue), repo.installation_id, :issue
      end

      # GET コミット取得
      def github_exec_fetch_commits!(pull)
        _get sub_url(:commit, pull), pull.repo.installation_id, :commit
      end

      # GET 前のコミットのファイル差分取得
      # ref: https://developer.github.com/v3/repos/commits/#get-a-single-commit
      def github_exec_fetch_changed_files!(commit)
        _get "repos/#{commit.pull.repo_full_name}/commits/#{commit.sha}", commit.pull.repo.installation_id, :changed_file
      end

      # GET ファイル差分取得
      # ref: https://developer.github.com/v3/repos/commits/#compare-two-commits
      def github_exec_fetch_diff!(pull)
        _get URI.encode("repos/#{pull.repo_full_name}/compare/#{pull.base_label}...#{pull.head_label}"), pull.repo.installation_id, :diff
      end

      # GET 組織取得
      def github_exec_fetch_orgs!(github_account)
        _get_credential_resource "user/orgs", :org, github_account.access_token
      end

      # GET レビュイーの組織内での役割を取得する
      def github_exec_fetch_role_in_org!(github_account, org_name)
        _get_credential_resource "orgs/#{org_name}/memberships/#{github_account.login}", :role_in_org, github_account.access_token
      end

      def github_exec_fetch_issue_by_number(repo, issue_number)
        _get "repos/#{repo.full_name}/issues/#{issue_number}", repo.installation_id, :issue_number
      end

      # GET 対象レポジトリ内のコードを検索する
      def github_exec_search_contents_scope_repo!(repo, keyword)
        headers = {
          'User-Agent': 'Mergee',
          'Authorization': "token #{get_access_token(repo.installation_id)}",
          'Accept': set_accept(:search_code)
        }
        sub_url = "search/code?q=#{keyword}+in:file+repo:#{repo.full_name}"
        res = get Settings.api.github.api_domain + sub_url, headers: headers
        unless res.code == success_code(:search_code)
          logger.error "[Github][:search_code] responseCode => #{res.code}"
          logger.error "[Github][:search_code] responseMessage => #{res.message}"
          logger.error "[Github][:search_code] subUrl => #{sub_url}"
        end
        res
      end

      private

      #
      # リクエストの送信処理
      #
      # @param [String] sub_url github api urlの後続のURL ex. /repos/:owner/:repo/pulls/comments/:comment_id
      # @param [Hash] params 送信パラメータ { path: xxxx, position: yyyy, body: zzzz }
      #
      def _post(sub_url, installation_id, event, params)
        headers = {
          'User-Agent': 'Mergee',
          'Authorization': "token #{get_access_token(installation_id)}",
          'Accept': set_accept(event)
        }

        res = post Settings.api.github.api_domain + sub_url, headers: headers, body: params

        unless res.code == success_code(event)
          logger.error "[Github][#{event}] responseCode => #{res.code}"
          logger.error "[Github][#{event}] responseMessage => #{res.message}"
          logger.error "[Github][#{event}] subUrl => #{sub_url}"
        end
        res
      end

      def _get(sub_url, installation_id, event)
        headers = {
          'User-Agent': 'PushRequest',
          'Authorization': "token #{get_access_token(installation_id)}",
          'Accept': set_accept(event)
        }

        res = get Settings.api.github.api_domain + sub_url, headers: headers

        unless res.code == success_code(event)
          logger.error "[Github][#{event}] responseCode => #{res.code}"
          logger.error "[Github][#{event}] responseMessage => #{res.message}"
          logger.error "[Github][#{event}] subUrl => #{sub_url}"
        end
        res
      end

      # Organazation, Membership
      def _get_credential_resource(sub_url, event, access_token)
        headers = {
          'User-Agent': 'PushRequest',
          'Authorization': "token #{access_token}",
          'Accept': set_accept(event)
        }

        res = get Settings.api.github.api_domain + sub_url, headers: headers

        unless res.code == success_code(event)
          logger.error "[Github][#{event}] responseCode => #{res.code}"
          logger.error "[Github][#{event}] responseMessage => #{res.message}"
          logger.error "[Github][#{event}] subUrl => #{sub_url}"
        end
        res
      end

      def get_access_token(installation_id)
        request_url = Settings.api.github.request.access_token_uri + installation_id.to_s + '/access_tokens'
        headers = {
          'User-Agent': 'Mergee',
          'Authorization': "Bearer #{get_jwt}",
          'Accept': set_accept(:get_access_token)
        }

        res = post request_url, headers: headers

        res = JSON.load(res.body)
        access_token = res['token']
        access_token
      end

      def get_jwt
        # Private key contents
        private_pem = Rails.env.production? ? ENV['PRIVATE_PEM'] : File.read(ENV['PATH_TO_PEM_FILE'])
        private_key = OpenSSL::PKey::RSA.new(private_pem)
        # Generate the JWT
        payload = {
          # issued at time
          iat: Time.now.to_i,
          # JWT expiration time (10 minute maximum)
          exp: Time.now.to_i + (10 * 60),
          # GitHub App's identifier
          iss: ENV['GITHUB_APP_PAYLOAD_ISS_ID']
        }

        jwt = JWT.encode payload, private_key, 'RS256'
        jwt
      end

      # イベントに対応するacceptを返す
      def set_accept(event)
        case event
        when *%i(review get_access_token) then Settings.api.github.request.header.accept.machine_man_preview_json
        when *%i(issue_comment) then Settings.api.github.request.header.accept.machine_man_preview
        when *%i(changed_file pull content issue commit diff org role_in_org issue_number) then Settings.api.github.request.header.accept.symmetra_preview_json
        when *%i(review_comment) then Settings.api.github.request.header.accept.squirrel_girl_preview
        when *%i(search_code) then Settings.api.github.request.header.accept.text_match_json
        end
      end

      # 成功時のレスポンスコード
      def success_code(event)
        case event
        when *%i(issue_comment changed_file pull review_comment) then Settings.api.created.status.code
        when *%i(content commit issue diff review org role_in_org issue_number search_code) then Settings.api.success.status.code
        end
      end

      def sub_url(event, pull)
        case event
        when :review then "repos/#{pull.repo_full_name}/pulls/#{pull.number}/reviews"
        when :issue_comment then "repos/#{pull.repo_full_name}/issues/#{pull.number}/comments"
        when :changed_file then "repos/#{pull.repo_full_name}/pulls/#{pull.number}/files"
        when :review_comment then "repos/#{pull.repo_full_name}/pulls/#{pull.number}/comments"
        when :commit then "repos/#{pull.repo_full_name}/pulls/#{pull.number}/commits"
        end
      end

      def sub_url_for(repo, event)
        case event
        when :issue then "repos/#{repo.full_name}/issues?state=all"
        when :pull then "repos/#{repo.full_name}/pulls"
        end
      end

      #
      # ログをRailsのものを流用する
      #
      # @return [Logger]
      #
      def logger
        Rails.logger
      end
    end
  end
end
