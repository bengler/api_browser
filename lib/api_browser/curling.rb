require 'curb'
require 'oauth'
require 'oauth/request_proxy/curb_request'

OAuth::RequestProxy::Curl::Easy.class_eval do
  def method
    options[:method]
  end
  def post_parameters
    options[:post_data].inject({}) do |mem, data|
      mem[data.name] = data.content
      mem
    end
  end
end

module ApiBrowser
  module Curling
    module Helpers

      def oauth_consumer
        @consumer ||= OAuth::Consumer.new(settings.oauth[:key], settings.oauth[:secret], :site => settings.url)
      end

      def access_token(token, secret)
        OAuth::AccessToken.from_hash(oauth_consumer, {
          :oauth_token => token,
          :oauth_token_secret => secret
        })
      end

      def access_token_from_request(token, secret, verifier)
        rt = OAuth::RequestToken.new( oauth_consumer, token, secret)
        rt.get_access_token(:oauth_verifier => verifier)
      end
    end
  end
end
