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
        # @param digital_object [DigitalObject, nil]
        # @param target_url [String]
        # @param publish [Boolean]
        # @return [String] a new id
        def mint_impl(digital_object, target_url, publish)
          new_id = Random.rand.to_s
          loop do
            break unless @identifiers.key?(new_id)
            new_id = Random.rand.to_s
          end
          state = publish ? :findable : :draft
          @identifiers[new_id] = { uid: digital_object&.uid, status: :inactive, target_url: target_url, state: state }.compact
          new_id
        end

        # Returns true if an identifier exists in the external management system
        def exists?(id)
          @identifiers.key? id
        end

        # @param id [String]
        # @param digital_object [DigitalObject]
        # @param target_url [String]
        # @param publish [Boolean]
        # @return [Boolean] true if this adapter can handle this type of identifier
        def update_impl(id, digital_object, target_url, state)
          return false unless handles?(id)
          state = publish ? :findable : :registered
          @identifiers[id] = { uid: digital_object.uid, status: :active, target_url: target_url, state: state }
          true
        end

        def deactivate_impl(id)
          return false unless exists?(id)
          @identifiers[id][:status] = :inactive
          true
        end

        def tombstone_impl(_id)
          # TODO: See HYACINTH-876
        end
      end
    end
  end
end
