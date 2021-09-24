# frozen_string_literal: true

module Hyacinth
  module Adapters
    module ExternalIdentifierAdapter
      class Memory < Abstract
        attr_reader :identifiers

        def initialize(adapter_config = {})
          super(adapter_config)
          @identifiers = {}
        end

        # @param id [String]
        # @return [Boolean] true if this adapter can handle this type of identifier
        def handles?(_id)
          true
        end

        # Generates a new persistent id, ensuring that nothing currently uses that identifier.
        # @return [String] a new id
        def mint(**_args)
          new_id = Random.rand.to_s
          loop do
            break unless @identifiers.key?(new_id)
            new_id = Random.rand.to_s
          end
          @identifiers[new_id] = {}
          new_id
        end

        # Returns true if an identifier exists in the external management system
        def exists?(id)
          @identifiers.key? id
        end

        # @param id [String]
        # @param digital_object [DigitalObject]
        # @param location_uri [String]
        # @return [Boolean] true if this adapter can handle this type of identifier
        def update_impl(id, digital_object, location_uri)
          return false unless handles?(id)
          @identifiers[id] = { uid: digital_object.uid, status: :active }
          update_location_uri(id, location_uri)
          true
        end

        # Following method will make a request to the EZID server to update the target URL associated
        # with the EZID DOI entry on the server.
        # (See _target in http://ezid.cdlib.org/doc/apidoc.html#internal-metadata)
        # To delete the target URL stored in the DOI server, use an empty string as the argument.
        # Uses the modify identifier API call, returns true if metadata update was successful
        # if not, returns false
        def update_location_uri(doi, target_url)
          return false unless exists?(doi)
          @identifiers[doi][:location_uri] = target_url
          true
        end

        def tombstone_impl(id)
          return false unless exists?(id)
          @identifiers[id][:status] = :inactive
          true
        end
      end
    end
  end
end
