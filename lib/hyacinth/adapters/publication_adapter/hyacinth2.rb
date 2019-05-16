module Hyacinth
  module Adapters
    module PublicationAdapter
      class Hyacinth2 < Abstract
        def initialize(adapter_config = {})
          super
        end

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
        def publish(publish_target, digital_object, point_doi_to_this_publish_target)
          digital_object_pid = digital_object_pids(digital_object).first
          return [false, "Never preserved to Fedora3"] unless digital_object_pid
          connection = Faraday.new(publish_target.publish_url)
          connection.token_auth(publish_target.api_key)
          resp = connection.put(digital_object_pid)
          location = resp.headers['Location']
          update_doi(digital_object, location) if point_doi_to_this_publish_target && location
          [true]
        rescue StandardError => e
          [false, e.message]
        end

        # @return [success, errors] [boolean, Array<String>] success will be true if
        #         the unpublish was successful, or false otherwise. errors is an array
        #         that will contain error messages if the unpublish failed.
        def unpublish(publish_target, digital_object, point_doi_to_this_publish_target)
          digital_object_pid = digital_object_pids(digital_object).first
          return [false, "Never preserved to Fedora3"] unless digital_object_pid
          connection = Faraday.new(publish_target.publish_url)
          connection.token_auth(publish_target.api_key)
          connection.delete(digital_object_pid)
          tombstone_doi(digital_object) if point_doi_to_this_publish_target
          [true]
        rescue StandardError => e
          [false, e.message]
        end

        def digital_object_pids(hyacinth_obj)
          # TODO: DRY out the FCR3 URI detection with pres adapter
          uri_prefix = "fedora3://"
          fcr3_uris = hyacinth_obj.preservation_target_uris.select { |x| x.start_with? uri_prefix }
          fcr3_uris.map { |fcr3_uri| "info:fedora/#{fcr3_uri[uri_prefix.length..-1]}" }
        end
      end
    end
  end
end
