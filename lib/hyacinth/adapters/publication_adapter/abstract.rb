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
        def publish(publish_target, digital_object, point_doi_to_this_publish_target)
          result = publish_impl(publish_target, digital_object)
          update_doi(digital_object, result[1].first) if result[0] && citation_changed?(digital_object, result[1].first) && point_doi_to_this_publish_target
          result
        rescue StandardError => e
          [false, [e.message]]
        end

        def publish_impl(_publish_target, _digital_object)
          raise NotImplementedError
        end

        # @return [success, errors] [boolean, Array<String>] success will be true if
        #         the unpublish was successful, or false otherwise. errors is an array
        #         that will contain error messages if the unpublish failed.
        def unpublish(publish_target, digital_object, point_doi_to_this_publish_target)
          result = unpublish_impl(publish_target, digital_object)
          tombstone_doi(digital_object) if result[0] && point_doi_to_this_publish_target && point_doi_to_this_publish_target
          result
        rescue StandardError => e
          [false, [e.message]]
        end

        def unpublish_impl(_publish_target, _digital_object)
          raise NotImplementedError
        end

        def citation_changed?(digital_object, published_location)
          last_citation = digital_object.publish_entries.detect { |_string_key, entry| entry.cited_at }
          last_location = last_citation[1].cited_at if last_citation
          last_cited = last_citation[1].published_at if last_citation
          return true unless published_location.eql?(last_location)
          # if the locations are equal, check the dates of update and compare to last citation
          last_cited.nil? || last_cited < digital_object.updated_at
        end

        # Update the DOI's published metadata
        # TODO: Remove this in favor of adapter/service?
        def update_doi(digital_object, location)
          Hyacinth.config.external_identifier_adapter.update(digital_object.doi, digital_object, location)
        end

        # Mark the DOI as inactive
        # TODO: Remove this in favor of adapter/service?
        def tombstone_doi(digital_object)
          Hyacinth.config.external_identifier_adapter.tombstone(digital_object.doi)
        end
      end
    end
  end
end
