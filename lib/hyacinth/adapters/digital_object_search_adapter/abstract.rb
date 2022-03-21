# frozen_string_literal: true

module Hyacinth
  module Adapters
    module DigitalObjectSearchAdapter
      class Abstract
        attr_reader :ui_config

        def initialize(adapter_config = {})
          @ui_config = UiConfig.new(adapter_config.fetch(:ui_config, {}))
        end

        def index(digital_object, **opts)
          raise NotImplementedError
        end

        # Runs an indexing test, generating an indexable document but not actually
        # adding that document to the search index.
        # @return [Boolean] true if document generation suceeds, or false if it fails
        def index_test(digital_object)
          raise NotImplementedError
        end

        def remove(digital_object, **opts)
          raise NotImplementedError
        end

        def search(search_params, **opts)
          raise NotImplementedError
        end

        def commit
          raise NotImplementedError
        end

        # Returns true if the given field_path is in use by records in the specified project.
        # You can also pass an option digital_object_type if you want to only check if the field
        # is in use by objects of a certain type within the specified project.
        def field_used_in_project?(field_path, project, digital_object_type = nil)
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

      class UiConfig
        DEFAULT_FACET_PAGE_SIZE = 10
        attr_reader :config

        def initialize(adapter_config = {})
          @config = adapter_config
        end

        def facet_page_size
          config.fetch(:facet_page_size, DEFAULT_FACET_PAGE_SIZE)
        end
      end
    end
  end
end
