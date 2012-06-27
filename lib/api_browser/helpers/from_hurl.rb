module ApiBrowser
  module Helpers
    module FromHurl

      # render a json response
      def json(hash = {})
        content_type 'application/json'
        Yajl::Encoder.encode(hash)
      end

      # turn post_data into a string for PUT requests
      def stringify_data(data)
        if data.is_a? String
          data
        elsif data.is_a? Array
          data.map { |x| stringify_data(x) }.join("&")
        elsif data.is_a? Curl::PostField
          data.to_s
        else
          raise "Cannot stringify #{data.inspect}"
        end
      end

      # headers from non-empty keys and values
      def add_headers_from_arrays(curl, keys, values)
        keys, values = Array(keys), Array(values)

        keys.each_with_index do |key, i|
          next if values[i].to_s.empty?
          curl.headers[key] = values[i]
        end
      end

      # post params from non-empty keys and values
      def make_fields(method, keys, values)
        return [] unless %w( POST PUT ).include? method

        fields = []
        keys, values = Array(keys), Array(values)
        keys.each_with_index do |name, i|
          value = values[i]
          next if name.to_s.empty? || value.to_s.empty?
          fields << Curl::PostField.content(name, value)
        end
        fields
      end
    end
  end
end

