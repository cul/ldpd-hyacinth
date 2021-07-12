# frozen_string_literal: true

module Hyacinth
  module Adapters
    module PublicationAdapter
      class Abstract
        def initialize(_adapter_config = {}); end

        # Publishes the given digital object to this publish target's url.
        # @param digital_object [DigitalObject subclass] DigitalObject to publish.
        # @return [success, errors] [boolean, Array<String>] success will be true if
        #         the publish was successful, or false otherwise. errors is an array
        #         that will contain error messages if the publish failed.
        def publish(publish_target, digital_object)
          publish_impl(publish_target, digital_object)
        rescue StandardError => e
          [false, [e.message]]
        end

        def publish_impl(_publish_target, _digital_object)
          raise NotImplementedError
        end

        # @return [success, errors] [boolean, Array<String>] success will be true if
        #         the unpublish was successful, or false otherwise. errors is an array
        #         that will contain error messages if the unpublish failed.
        def unpublish(publish_target, digital_object)
          unpublish_impl(publish_target, digital_object)
        rescue StandardError => e
          [false, [e.message]]
        end

        def unpublish_impl(_publish_target, _digital_object)
          raise NotImplementedError
        end
      end
    end
  end
end
