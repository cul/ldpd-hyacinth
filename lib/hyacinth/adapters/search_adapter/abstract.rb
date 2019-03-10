module Hyacinth
  module Adapters
    module SearchAdapter
      class Abstract
        def initialize(adapter_config = {})
        end

        def index(digital_object)
          raise NotImplementedError
        end

        def search(search_params)
          raise NotImplementedError
        end
      end
    end
  end
end
