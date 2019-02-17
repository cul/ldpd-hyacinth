module Hyacinth
  module Adapters
    module SearchAdapter
      class Solr < Abstract
        def initialize(adapter_config = {})
          super(adapter_config)
        end
      end
    end
  end
end
