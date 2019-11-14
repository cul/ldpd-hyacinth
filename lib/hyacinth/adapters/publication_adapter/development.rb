module Hyacinth
  module Adapters
    module PublicationAdapter
      class Development < Abstract
        def initialize(adapter_config = {})
          super
        end

        # Mocks the publishing action by returning a successful response. Ensures that
        # object was preserved before "publishing".
        #
        # @param digital_object [DigitalObject::Base subclass] DigitalObject to publish.
        # @param publish_target
        # @return [success, msg] [boolean, Array<String>] success will be true and message will be a
        #         fake url location
        def publish_impl(publish_target, digital_object)
          digital_object_pid = digital_object_fedora_uris(digital_object).first
          return [false, "Never preserved to Fedora3"] unless digital_object_pid

          [true, ["https://example.com/#{publish_target.string_key}/#{digital_object.uid}"]]
        rescue StandardError => e
          [false, [e.message]]
        end

        # Mocks unpublishing action by returning a successful response. Ensures that object
        # was preserved before "unpublishing".
        #
        # @return [success, errors] [boolean, Array<String>] success will be true if
        #         the unpublish was successful, or false otherwise. errors is an array
        #         that will contain error messages if the unpublish failed.
        def unpublish_impl(_publish_target, digital_object)
          digital_object_pid = digital_object_fedora_uris(digital_object).first
          return [false, "Never preserved to Fedora3"] unless digital_object_pid

          [true]
        rescue StandardError => e
          [false, [e.message]]
        end
      end
    end
  end
end
