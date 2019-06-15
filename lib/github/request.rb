module Github
  class Request # rubocop:disable Metrics/ClassLength
    include HTTParty

    class << self
      BASE_API_URI = 'https://api.github.com'.freeze

      def pulls(repo)
        _get sub_url_for(repo, :pull), repo.installation_id, :pull
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

        res = get "#{BASE_API_URI}/#{sub_url}", headers: headers

        unless res.code == success_code(event)
          logger.error "[Github][#{event}] responseCode => #{res.code}"
          logger.error "[Github][#{event}] responseMessage => #{res.message}"
          logger.error "[Github][#{event}] subUrl => #{sub_url}"
        end
        res
      end

      def get_access_token(installation_id)
        request_url = "#{BASE_API_URI}/installations/#{installation_id}/access_tokens"
        headers = {
          'User-Agent': 'CodeReview',
          'Authorization': "Bearer #{get_jwt}",
          'Accept': set_accept(:get_access_token)
        }

        response = post request_url, headers: headers

        res = JSON.parse response.body, symbolize_names: true
        res[:token]
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
        when :get_access_token then Settings.api.github.request.header.accept.machine_man_preview_json
        when :pull then Settings.api.github.request.header.accept.symmetra_preview_json
        end
      end

      # 成功時のレスポンスコード
      def success_code(event)
        case event
        when :pull then Settings.api.created.status.code
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
