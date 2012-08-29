require 'sinatra/base'
require 'json'
require 'yajl'
require 'coderay'
require 'yard'

unless defined?(require_relative)
  alias :require_relative :require  # Ruby 1.8
end

require_relative 'hurl'
require_relative "api_browser/version"
require_relative 'api_browser/curling'
require_relative 'api_browser/endpoint'
require_relative 'api_browser/parser'
require_relative 'api_browser/curling'
require_relative "api_browser/helpers/session"
require_relative "api_browser/helpers/from_hurl"
require_relative "api_browser/app"

module ApiBrowser
  def self.config(options)
    ApiBrowser::App.instance_eval do
      # Session
      session_defaults = {:key => '_api_browser', :secret => 'api_secret'}
      session = options.delete :session
      session ||= session_defaults
      use Rack::Session::Cookie, session.merge(session_defaults)

      # The rest
      options.each { |key, value| set key, value }
    end
  end
end