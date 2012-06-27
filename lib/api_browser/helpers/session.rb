module ApiBrowser
  module Helpers
    module Session

      def logout!
        session[:oauth_token] = nil
      end

      def authenticate!
        callback_url = "#{base_url}/login/callback"
        request_token = oauth_consumer.get_request_token(:oauth_callback => callback_url)
        session[:request_token] = request_token.token
        session[:request_token_secret] = request_token.secret
        redirect request_token.authorize_url
      end

      def authenticated?
        !!session[:oauth_token]
      end

    end
  end
end

