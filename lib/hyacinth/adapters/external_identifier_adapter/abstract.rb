# frozen_string_literal: true

module Hyacinth
  module Adapters
    module ExternalIdentifierAdapter
      class Abstract
        def initialize(adapter_config = {}); end

        # @param id [String]
        # @return [Boolean] true if this adapter can handle this type of identifier
        def handles?(_id)
          raise NotImplementedError
        end

        # Generates a new persistent id, ensuring that nothing currently uses that identifier.
        # @return [String] a new id
        def mint(**_args)
          raise NotImplementedError
        end

        # Returns true if an identifier exists in the external management system
        def exists?(_id)
          raise NotImplementedError
        end

        # @param id [String]
        # @param digital [String]
        # @return [Boolean] true if this adapter can handle this type of identifier
        def update(id, digital_object, location_uri)
          raise Hyacinth::Exceptions::UnhandledLocationError, "Unhandled id for #{self.class.name}: #{id}" unless handles?(id)
          update_impl(id, digital_object, location_uri)
        end

        def update_impl(_id, _digital_object, _location_uri)
          raise NotImplementedError
        end

        def tombstone(id)
          raise Hyacinth::Exceptions::UnhandledLocationError, "Unhandled id for #{self.class.name}: #{id}" unless handles?(id)
          tombstone_impl(id)
        end

        def tombstone_impl(_id)
          raise NotImplementedError
        end
      end
    end
  end
end
