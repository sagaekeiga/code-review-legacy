module Github
  class Request
    include HTTParty

    class << self
      BASE_API_URI = 'https://api.github.com'.freeze

      def pulls(repo)
        headers = set_headers(repo.installation_id)
        url = "#{BASE_API_URI}/repos/#{repo.full_name}/pulls"

        res = get url, headers: headers

        JSON.parse res.body, symbolize_names: true
      end

      def languages(repo:)
        headers = set_headers(repo.installation_id)
        url = "#{BASE_API_URI}/repos/#{repo.full_name}/languages"

        res = get url, headers: headers

        JSON.parse res.body, symbolize_names: true
      end

      def review_comments(pull)
        headers = set_headers(pull.installation_id)
        url = "#{BASE_API_URI}/repos/#{pull.full_name}/pulls/#{pull.number}/comments"

        res = get url, headers: headers

        JSON.parse res.body, symbolize_names: true
      end

      def repo(repo_params, params)
        headers = set_headers(params[:installation][:id])
        url = "#{BASE_API_URI}/repos/#{repo_params[:full_name]}"

        res = get url, headers: headers

        JSON.parse res.body, symbolize_names: true
      end

      private

      def get_access_token(installation_id)
        request_url = "#{BASE_API_URI}/installations/#{installation_id}/access_tokens"
        headers = {
          'User-Agent': 'CodeReview',
          'Authorization': "Bearer #{get_jwt}",
          'Accept': Settings.api.github.request.header.accept.machine_man_preview_json
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

      def set_headers(installation_id)
        {
          'User-Agent': 'CodeReview',
          'Authorization': "token #{get_access_token(installation_id)}",
          'Accept': 'application/vnd.github.antiope-preview+json'
        }
      end
    end
  end
end
