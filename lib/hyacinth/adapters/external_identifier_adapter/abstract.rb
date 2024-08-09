# frozen_string_literal: true

module Hyacinth
  module Adapters
    module ExternalIdentifierAdapter
      class Abstract
        def initialize(adapter_config = {})
          @default_target_url_template = adapter_config[:default_target_url_template]
        end

        # @param id [String]
        # @return [Boolean] true if this adapter can handle this type of identifier
        def handles?(_id)
          raise NotImplementedError
        end

        # Generates a new persistent id, ensuring that nothing currently uses that identifier.
        # @return [String] a new id
        def mint(digital_object: nil, target_url: nil, publish: false)
          target_url_value = ensure_target_url(digital_object, target_url)
          mint_impl(digital_object, target_url_value, publish)
        end

        def mint_impl(_digital_object, _target_url, _state)
          raise NotImplementedError
        end

        # Returns true if an identifier exists in the external management system
        def exists?(_id)
          raise NotImplementedError
        end

        # @param id [String]
        # @param digital [String]
        # @return [Boolean] true if this adapter can handle this type of identifier
        def update(id:, digital_object:, target_url:, publish: true)
          raise Hyacinth::Exceptions::UnhandledLocationError, "Unhandled id for #{self.class.name}: #{id}" unless handles?(id)
          target_url_value = ensure_target_url(digital_object, target_url)
          update_impl(id, digital_object, target_url_value, publish)
        end

        def update_impl(_id, _digital_object, _target_url, _state)
          raise NotImplementedError
        end

        def deactivate(id)
          raise Hyacinth::Exceptions::UnhandledLocationError, "Unhandled id for #{self.class.name}: #{id}" unless handles?(id)
          deactivate_impl(id)
        end

        def deactivate_impl(_id)
          raise NotImplementedError
        end

        def tombstone(id)
          raise Hyacinth::Exceptions::UnhandledLocationError, "Unhandled id for #{self.class.name}: #{id}" unless handles?(id)
          tombstone_impl(id)
        end

        def tombstone_impl(_id)
          raise NotImplementedError
        end

        # @param digital_object [DigitalObject]
        # @param target_url [String] optional URL to be associated with digital_object's external ID
        # @api private
        # @return [String, nil] a default target URL to associate with the digital object
        def ensure_target_url(digital_object, target_url = nil)
          return target_url if target_url.present?
          return nil unless digital_object
          format(@default_target_url_template, uid: digital_object.uid) if @default_target_url_template
        end
      end
    end
  end
end
