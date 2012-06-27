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
      self.method = yardoc.tags(:http)[0].text
      self.path   = yardoc.tags(:path)[0].text
      self.docstring = yardoc.docstring
      if yardoc.tags(:category).any?
        self.category = yardoc.tags(:category)[0].text
      end
      self.status = yardoc.tags(:status).map do |s|
        {
          :code => s.name.to_i,
          :doc  => s.text
        }
      end
      self.status.sort_by!{|s| s[:code]}
      self.params = [yardoc.tags(:required), yardoc.tags(:optional)].flatten.map do |param|
        {
          :name  => param.name,
          :types => param.types,
          :doc   => param.text,
          :type  => param.tag_name
        }
      end

      self.example = yardoc.tags(:example)[0].name
      if yardoc.tags(:example)[0].text
        self.example_params = yardoc.tags(:example)[0].text.split.map {|p| p.split(':')}
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
