# frozen_string_literal: true

module Hyacinth
  module Adapters
    module DigitalObjectSearchAdapter
      class Abstract
        def initialize(adapter_config = {})
        end

        def index(digital_object)
          raise NotImplementedError
        end

        def remove(digital_object)
          raise NotImplementedError
        end

        def search(search_params)
          raise NotImplementedError
        end

        # Returns the uids associated with the given identifier
        # @param identifier
        # @param opts
        #        opts[:retry_with_delay] If no results are found, search again after the specified delay (in seconds).
        def identifier_to_uids(identifier, opts)
          raise NotImplementedError
        end

        # Deletes all records from the search index
        def clear_index
          raise NotImplementedError
        end
      end
    end
  end
end
