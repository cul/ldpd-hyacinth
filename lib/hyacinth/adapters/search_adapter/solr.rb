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

        # Returns the uids associated with the given identifier
        # @param identifier
        # @param opts
        #        opts[:retry_with_delay] If no results are found, search again after the specified delay (in seconds).
        def identifier_to_uids(identifier, opts)
          2.times do
            # TODO: Search

            if opts[:retry_with_delay].present?
              sleep opts[:retry_with_delay]
            else
              break
            end
          end
        end

        # Deletes all records from the search index
        def clear_index
          # TODO: Clear all records from solr
        end
      end
    end
  end
end
