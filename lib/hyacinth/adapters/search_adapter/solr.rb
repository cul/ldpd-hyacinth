module Hyacinth
  module Adapters
    module SearchAdapter
      class Solr < Abstract
        def initialize(adapter_config = {})
          super(adapter_config)
        end

        def index(digital_object)
          # TODO: Index this object into solr
        end

        def search(search_params)
          # TODO: Return search results
        end
      end
    end
  end
end
