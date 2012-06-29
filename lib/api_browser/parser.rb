YARD::Config.load_plugin("sinatra")

YARD::Tags::Library.define_tag("API Doc", :apidoc)
YARD::Tags::Library.define_tag("Endpoint path", :path)
YARD::Tags::Library.define_tag("Category", :category)
YARD::Tags::Library.define_tag("API example", :example, :with_name)
YARD::Tags::Library.define_tag("HTTP verb", :http)
YARD::Tags::Library.define_tag("Return status", :status, :with_name)
YARD::Tags::Library.define_tag("Required param", :required, :with_types_and_name)
YARD::Tags::Library.define_tag("Optional param", :optional, :with_types_and_name)

module ApiBrowser
  class Parser
    def self.parse(paths)
      paths.each do |path|
        YARD.parse path
      end
      # Only keep stuff with @path on it
      YARD::Registry.all.reject {|r| r.tags(:apidoc).empty?}.map {|t| Endpoint.new(t)}.sort_by(&:path)
    end
  end
end

