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
        def mint_impl(_digital_object, _location_uri, _state)
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
        def update_impl(id, digital_object, location_uri, state)
          return false unless handles?(id)
          @identifiers[id] = { uid: digital_object.uid, status: :active, location_uri: location_uri, state: state }
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
