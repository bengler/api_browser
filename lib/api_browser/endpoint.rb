module ApiBrowser
  # This class exists to try to minimize the memory footprint by not using the
  # YARD-tags, which are probably bloated for our use
  class Endpoint
    attr_accessor :method,
      :path,
      :docstring,
      :params,
      :example,
      :example_params,
      :category,
      :status

    def initialize(yardoc)
      @yardoc = yardoc
      parse
    end

    def parse
      self.method = @yardoc.tags(:http)[0].try(:text)
      self.method ||= 'GET'

      self.path   = @yardoc.tags(:path)[0].try(:text)
      self.docstring = @yardoc.docstring
      if @yardoc.tags(:category).any?
        self.category = @yardoc.tags(:category)[0].try(:text)
      else
        self.category = 'Uncategorized'
      end
      self.status = @yardoc.tags(:status).map do |s|
        {
          :code => s.name.to_i,
          :doc  => s.text
        }
      end
      self.status = self.status.sort_by { |s| s[:code] }
      self.params = [@yardoc.tags(:required), @yardoc.tags(:optional)].flatten.map do |param|
        {
          :name  => param.name,
          :types => param.types,
          :doc   => param.text,
          :type  => param.tag_name
        }
      end

      self.example = @yardoc.tags(:example)[0].try(:name)
      self.example ||= self.path
      if @yardoc.tags(:example)[0].try(:text)
        self.example_params = @yardoc.tags(:example)[0].text.split.map {|p| p.split(':')}
      end
    end

    # The path used in the sinatra app for this endpoint in
    # 
    # get /(\/.*)/
    #
    def doc_path
      "#{path}.#{method}"
    end
  end

end
