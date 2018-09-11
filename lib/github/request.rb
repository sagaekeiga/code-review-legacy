module Github
  class Request
    include HTTParty

    class << self

      # POST レビュー送信
      def github_exec_review!(params, pull)
        _post sub_url(:review, pull), pull.repo.installation_id, :review, params
      end

      # POST コメント送信
      def github_exec_issue_comment!(params, pull)
        _post sub_url(:issue_comment, pull), pull.repo.installation_id, :issue_comment, params
      end

      # POST リプライ送信
      def github_exec_review_comment!(params, pull)
        _post sub_url(:review_comment, pull), pull.repo.installation_id, :review_comment, params
      end

      # GET ファイル差分取得
      def github_exec_fetch_changed_files!(pull)
        _get sub_url(:changed_file, pull), pull.repo.installation_id, :changed_file
      end

      # GET プルリクエスト取得
      def github_exec_fetch_pulls!(repo)
        _get sub_url(:pull, repo), repo.installation_id, :pull
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
          'User-Agent': 'PushRequest',
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

      def get_access_token(installation_id)
        request_url = Settings.api.github.request.access_token_uri + installation_id.to_s + '/access_tokens'
        headers = {
          'User-Agent': 'PushRequest',
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
        when :review, :get_access_token
          return Settings.api.github.request.header.accept.review
        when :issue_comment
          return Settings.api.github.request.header.accept.issue_comment
        when :changed_file
          return Settings.api.github.request.header.accept.changed_file
        when :pull
          return Settings.api.github.request.header.accept.pull
        when :review_comment
          return Settings.api.github.request.header.accept.review_comment
        end
      end

      # 成功時のレスポンスコード
      def success_code(event)
        case event
        when :review
          return Settings.api.success.status.code
        when :issue_comment
          return Settings.api.success.created.status
        when :changed_file
          return Settings.api.success.created.status
        when :pull
          return Settings.api.success.created.status
        when :review_comment
          return Settings.api.success.created.status
        end
      end

      def sub_url(event, pull)
        case event
        when :review
          return "repos/#{pull.repo_full_name}/pulls/#{pull.number}/reviews"
        when :issue_comment
          return "repos/#{pull.repo_full_name}/issues/#{pull.number}/comments"
        when :changed_file
          return "repos/#{pull.repo_full_name}/pulls/#{pull.number}/files"
        when :pull
          repo = pull
          return "repos/#{repo.full_name}/pulls"
        when :review_comment
          return "repos/#{pull.repo_full_name}/pulls/#{pull.number}/comments"
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