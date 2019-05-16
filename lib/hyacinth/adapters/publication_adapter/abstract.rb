module Hyacinth
  module Adapters
    module PublicationAdapter
      class Abstract
        def initialize(_adapter_config = {}); end

        # Publishes the given digital object to this publish target's url,
        # optionally pointing the doi to this publish target if
        # point_doi_to_this_publish_target is given a value of true.
        # @param digital_object [DigitalObject::Base subclass] DigitalObject to publish.
        # @param point_doi_to_this_publish_target [boolean] A flag that determines whether
        #        the published digital object's doi should point to a location associated
        #        with this PublishTarget.
        # @return [success, errors] [boolean, Array<String>] success will be true if
        #         the publish was successful, or false otherwise. errors is an array
        #         that will contain error messages if the publish failed.
        def publish(_publish_target, _digital_object, _point_doi_to_this_publish_target)
          raise NotImplementedError
        end

        # @return [success, errors] [boolean, Array<String>] success will be true if
        #         the unpublish was successful, or false otherwise. errors is an array
        #         that will contain error messages if the unpublish failed.
        def unpublish(_publish_target, _digital_object, _point_doi_to_this_publish_target)
          raise NotImplementedError
        end

        # Update the DOI's published metadata
        # TODO: Move this into an adapter/service?
        def update_doi(_digital_object, _location)
          raise NotImplementedError
        end

        # Update the DOI's published metadata
        # TODO: Move this into an adapter/service?
        def tombstone_doi(_digital_object)
          raise NotImplementedError
        end
      end
    end
  end
end
