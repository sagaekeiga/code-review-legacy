module Github
  class Request # rubocop:disable Metrics/ClassLength
    include HTTParty

    class << self
      BASE_API_URI = 'https://api.github.com'.freeze

      # POST レビュー送信
      def review(params:, pull:)
        _post sub_url(:review, pull), pull.repo.installation_id, :review, params
      end

      # POST リプライ送信
      def reply(params, pull)
        _post sub_url(:review_comment, pull), pull.repo.installation_id, :review_comment, params
      end

      # リポジトリファイルの取得（トップディレクトリ）
      def contents(repo:)
        res = get "#{BASE_API_URI}/repos/#{repo.full_name}/contents", headers: general_headers(installation_id: repo.installation_id, event: :contents)
        JSON.parse res, symbolize_names: true
      end

      # リポジトリファイルの取得（サブディレクトリ以下）
      def content(repo:, path: '')
        res = get "#{BASE_API_URI}/repos/#{repo.full_name}/contents/#{path}", headers: general_headers(installation_id: repo.installation_id, event: :contents)
        res = JSON.parse res, symbolize_names: true
        res[:message] ? res[:message] : res
      end

      # ファイル検索
      def search_contents(keyword:, repo:)
        res = get "#{BASE_API_URI}/search/code?q=#{keyword}+in:file+repo:#{repo.full_name}", headers: general_headers(installation_id: repo.installation_id, event: :search_code)
        JSON.parse res, symbolize_names: true
      end

      #
      # PR の file changes を返す
      # @param [Pull] pull
      # @return [Array<Hash>]
      #
      def files(pull:)
        repo = pull.repo

        queries = {
          per_page: 300
        }

        res = get "#{BASE_API_URI}/repos/#{repo.full_name}/pulls/#{pull.number}/files?#{queries.to_query}", headers: general_headers(installation_id: repo.installation_id, event: :contents)

        res = JSON.parse res, symbolize_names: true
        res
      end

      #
      # PR の file changes を返す
      # @param [Pull] pull
      # @return [Array<Hash>]
      #
      def ref_content(url:, installation_id:)
        res = get url, headers: general_headers(installation_id: installation_id, event: :contents)
        res = JSON.parse res, symbolize_names: true
        res[:message] ? res[:message] : res[:content]
      end

      # Readmeの取得
      def readme(repo:)
        res = get "#{BASE_API_URI}/repos/#{repo.full_name}/readme", headers: general_headers(installation_id: repo.installation_id, event: :contents)
        JSON.parse res, symbolize_names: true
      end

      # GET 差分ファイルの内容
      def github_exec_fetch_content_by_cf!(repo, sub_url)
        _get sub_url, repo.installation_id, :content
      end

      def changed_file_content(repo, content_url)
        headers = {
          'User-Agent': 'Mergee',
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
      def pulls(repo)
        _get sub_url_for(repo, :pull), repo.installation_id, :pull
      end

      # GET コミット取得
      def commits(pull:)
        headers = {
          'User-Agent': 'Mergee',
          'Authorization': "token #{get_access_token(pull.repo.installation_id)}",
          'Accept': set_accept(:commit)
        }

        queries = {
          per_page: 250
        }

        res = get "#{BASE_API_URI}/repos/#{pull.repo_full_name}/pulls/#{pull.number}/commits?#{queries.to_query}", headers: headers

        JSON.parse res.body, symbolize_names: true
      end

      # GET 前のコミットのファイル差分取得
      # ref: https://developer.github.com/v3/repos/commits/#get-a-single-commit
      def changed_files(commit)
        _get "repos/#{commit.pull.repo_full_name}/commits/#{commit.sha}", commit.pull.repo.installation_id, :changed_file
      end

      # GET ファイル差分取得
      # ref: https://developer.github.com/v3/repos/commits/#compare-two-commits
      def diff(pull)
        _get URI.encode("repos/#{pull.repo_full_name}/compare/#{pull.base_label}...#{pull.head_label}"), pull.repo.installation_id, :diff
      end

      def issue_by_number(repo, issue_number)
        _get "repos/#{repo.full_name}/issues/#{issue_number}", repo.installation_id, :issue_number
      end

      # GET レポジトリのZIPファイル
      # @see https://developer.github.com/v3/repos/contents/#get-archive-link
      def repo_archive(repo:, pull:)
        ref = pull.commits.last.sha
        headers = {
          'User-Agent': 'Mergee',
          'Authorization': "token #{get_access_token(repo.installation_id)}",
          'Accept': 'application/json'
        }
        res = get "#{BASE_API_URI}/repos/#{repo.full_name}/zipball/#{ref}", headers: headers

        unless res.code == success_code(:repo_zip)
          logger.error "[Github][#{:repo_zip}] responseCode => #{res.code}"
          logger.error "[Github][#{:repo_zip}] responseMessage => #{res.message}"
          logger.error "[Github][#{:repo_zip}] subUrl => #{BASE_API_URI}/repos/#{repo.full_name}/zipball/#{ref}"
        end
        res
      end

      private

      def general_headers(installation_id:, event:)
        {
          'User-Agent': 'Mergee',
          'Authorization': "token #{get_access_token(installation_id)}",
          'Accept': set_accept(event)
        }
      end

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
        JSON.parse res.body, symbolize_names: true
      end

      def _get(sub_url, installation_id, event)
        headers = {
          'User-Agent': 'Mergee',
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
        when :review, :get_access_token then Settings.api.github.request.header.accept.machine_man_preview_json
        when :changed_file, :pull, :content, :issue, :commit, :diff, :org, :role_in_org, :issue_number then Settings.api.github.request.header.accept.symmetra_preview_json
        when :review_comment then Settings.api.github.request.header.accept.squirrel_girl_preview
        when :search_code then Settings.api.github.request.header.accept.text_match_json
        end
      end

      # 成功時のレスポンスコード
      def success_code(event)
        case event
        when :changed_file, :pull, :review_comment then Settings.api.created.status.code
        when :content, :commit, :issue, :diff, :review, :org, :role_in_org, :issue_number, :search_code then Settings.api.success.status.code
        end
      end

      def sub_url(event, pull)
        case event
        when :review then "repos/#{pull.repo_full_name}/pulls/#{pull.number}/reviews"
        when :changed_file then "repos/#{pull.repo_full_name}/pulls/#{pull.number}/files"
        when :review_comment then "repos/#{pull.repo_full_name}/pulls/#{pull.number}/comments"
        end
      end

      def sub_url_for(repo, event)
        case event
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
