module Github
  class Request # rubocop:disable Metrics/ClassLength
    include HTTParty

    class << self
      BASE_API_URI = 'https://api.github.com'.freeze

      # Readmeの取得
      def readme(repo:)
        res = get "#{BASE_API_URI}/repos/#{repo.full_name}/readme", headers: general_headers(installation_id: repo.installation_id, event: :contents)
        res = JSON.parse res.body, symbolize_names: true
      end

      # GET プルリクエスト取得
      def pulls(repo)
        _get sub_url_for(repo, :pull), repo.installation_id, :pull
      end

      def languages(repo:)
        headers = {
          'User-Agent': 'Mergee',
          'Authorization': "token #{get_access_token(repo.installation_id)}",
          'Accept': 'application/vnd.github.antiope-preview+json'
        }
        url = "#{BASE_API_URI}/repos/#{repo.full_name}/languages"
        res = get url, headers: headers
        JSON.parse res.body, symbolize_names: true
      end

      private

      def general_headers(installation_id:, event:)
        {
          'User-Agent': 'Mergee',
          'Authorization': "token #{get_access_token(installation_id)}",
          'Accept': set_accept(event)
        }
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
