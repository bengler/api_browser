# coding: utf-8
module ApiBrowser
  class App < Sinatra::Base

    set :root, (File.dirname(__FILE__) + '/../../')

    set :endpoints, Proc.new { Parser.parse(doc_path.to_s)}

    helpers Curling::Helpers
    helpers Hurl::Helpers::PrettyPrinting
    helpers Hurl::Helpers::Sinatra

    helpers ApiBrowser::Helpers::Session
    helpers ApiBrowser::Helpers::FromHurl # copy pasted from Hurl

    helpers do
      def base_url
        default_port = (request.scheme == "http") ? 80 : 443
        port = (request.port == default_port) ? "" : ":#{request.port.to_s}"
        "#{request.scheme}://#{request.host}#{port}#{env['SCRIPT_NAME']}"
      end

      # FIXME: This hardcode is no good. Instead check url against endpoints
      def invalid_url?(url)
        !url.match /^\/api/
      end

    end

    before do
      if authenticated?
        @token = access_token(session[:oauth_token], session[:oauth_token_secret])
      end

      # FIXME: Replace these with sinatra flash message extension?
      @info = session.delete('info')
      @success = session.delete('success')
      @error = session.delete('error')
    end

    get '/?' do
      if authenticated?
        redirect base_url + settings.endpoints.first.doc_path
      else
        erb :login
      end
    end

    # Most of this is copy-pasted from hurl
    post '/' do
      url, method = params.values_at(:url, :method)

      return json(:error => "Invalid API endpoint") if invalid_url?(url)

      url = settings.url + url
      curl = Curl::Easy.new(url)
      sent_headers = []

      curl.on_debug do |type, data|
        # track request headers
        sent_headers << data if type == Curl::CURLINFO_HEADER_OUT
      end

      curl.follow_location = true

      # ensure a method is set
      method = (method.to_s.empty? ? 'GET' : method).upcase

      # arbitrary headers
      add_headers_from_arrays(curl, params["header-keys"], params["header-vals"])

      # arbitrary post params
      if params['post-body'] && ['POST', 'PUT'].index(method)
        post_data = [params['post-body']]
      else
        post_data = make_fields(method, params["param-keys"], params["param-vals"])
      end

      oauth_helper = OAuth::Client::Helper.new(curl, {
        :request_uri => url,
        :consumer => oauth_consumer,
        :token => @token,
        :method => method,
        :post_data => post_data
      })

      curl.headers.merge!({"Authorization" => oauth_helper.header})

      begin

        if method == 'PUT'
          # FIXME: stringify_data is missing. Copy it from hurl.it
          curl.http_put(stringify_data(post_data))
        else
          curl.send("http_#{method.downcase}", *post_data)
        end

        header  = pretty_print_headers(curl.header_str)
        type    = url =~ /(\.js)$/ ? 'js' : curl.content_type
        body    = pretty_print(type, curl.body_str)
        request = pretty_print_requests(sent_headers, post_data)

        json :header  => header,
          :body    => body,
          :request => request

      rescue Curl::Err::ConnectionFailedError
        json :error => "The target appilcation did not respond. Please try again later!"
      rescue => e
        json :error => CGI::escapeHTML(e.to_s)
      end
    end

    #######
    # Session stuff
    #######

    get '/login/?' do
      authenticate!
      redirect base_url + '/'
    end

    get '/login/callback/?' do
      begin
        access_token = access_token_from_request(session[:request_token],
                                                 session[:request_token_secret],
                                                 params[:oauth_verifier])
      rescue OAuth::Unauthorized => @exception
        session[:error] = "oauth error: #{@exception.message}"
        redirect base_url + '/' and return
      end

      session[:oauth_token] = access_token.token
      session[:oauth_token_secret] = access_token.secret
      session['success'] = 'You are now logged in'
      redirect base_url + '/'
    end

    get '/logout/?' do
      logout!
      session['info'] = 'You are now logged out'
      redirect base_url + '/'
    end

    # Catch-all API doc route, will render an Endpoint with views/doc.erb
    # if it exists
    get /(\/.*)/ do
      path = params[:captures].first

      if apidoc = settings.endpoints.find {|e| path == e.doc_path}
        @ctx = apidoc
        erb :doc
      else
        status 404
        erb :'404'
      end
    end
  end
end
