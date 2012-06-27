require 'sinatra/base'
require 'json'
require 'yajl'
require 'coderay'
require 'yard'

require_relative 'hurl'
require_relative "api_browser/version"
require_relative 'api_browser/curling'
require_relative 'api_browser/endpoint'
require_relative 'api_browser/parser'
require_relative 'api_browser/curling'
require_relative "api_browser/app"

module ApiBrowser
  def self.config(options)
    ApiBrowser::App.instance_eval do
      # Session
      session_defaults = { key: '_api_browser', secret: 'api_secret' }
      session = options.delete :session
      session ||= session_defaults
      use Rack::Session::Cookie, session.merge(session_defaults)

      # The rest
      options.each { |key, value| set key, value }
    end
  end
end

