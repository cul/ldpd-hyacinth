# frozen_string_literal: true

module Hyacinth
  module Adapters
    module ExternalIdentifierAdapter
      class Datacite < Abstract
        def initialize(adapter_config = {})
          @rest_api = adapter_config[:rest_api]
          @user = adapter_config[:user]
          @password = adapter_config[:password]
          @prefix = adapter_config[:prefix]
          super(adapter_config)
        end

        # @param id [String]
        # @return [Boolean] true if this adapter can handle this type of identifier
        def handles?(id)
          id =~ /^10\.[A-Za-z0-9]+\/[A-Za-z0-9\-]+/
        end

        # metadata is not required when minting a draft DOI.
        # metadata is required when minting a findable DOI. This metadata must include all the
        # properties required by DataCite.
        # It is also possible to specify a (non-existent) DOI when minting. However, this is not
        # currently supported in the code.
        # @param digital_object [DigitalObject]
        # @param target_url [String]
        # @param doi_state [Symbol] doi_state can be set to one of the following: :draft, :findable, :registered
        # @return [String] a new id
        def mint(digital_object: nil, target_url: nil, doi_state: :draft, **_args)
          if doi_state != :draft && digital_object.nil?
            Rails.logger.error "Hyacinth metadata required to mint DOI in #{doi_state} state"
            return
          end
          datacite_data = Datacite::RestApi::V2::Data.new(@prefix)
          datacite_data.update_properties(map_metadata(HyacinthMetadata.new(digital_object.as_json), target_url)) if digital_object
          datacite_data.build_mint(doi_state)
          rest_api = Datacite::RestApi::V2::Api.new(@rest_api, @user, @password)
          rest_api_response = rest_api.post_dois(datacite_data.generate_json_payload)
          unless rest_api_response.status.eql? 201
            Rails.logger.error "Did not mint a DOI! Response Code: #{rest_api_response.status}." \
                               "Response Body: #{rest_api_response.body}."
            return
          end
          rest_api.parse_doi_from_api_response_body(rest_api_response.body)
        end

        # Following only updates the DOI target url. Assumes the other required DataCite properties
        # are already set. If not sure, use update method and supply digital object.
        # return nil if unsuccessful, else returns the new target URL
        def update_location_uri(doi, target_url)
          datacite_data = Datacite::RestApi::V2::Data.new(@prefix)
          datacite_data.url = target_url
          datacite_data.build_properties_update
          rest_api = Datacite::RestApi::V2::Api.new(@rest_api, @user, @password)
          rest_api_response = rest_api.put_dois(doi, datacite_data.generate_json_payload)
          unless rest_api_response.status.eql? 200
            Rails.logger.error "Did not mint a DOI! Response Code: #{rest_api_response.status}." \
                               "Response Body: #{rest_api_response.body}."
            return
          end
          rest_api.parse_url_from_api_response_body(rest_api_response.body)
        end

        # @param hyacinth_metadata [HyacinthMetadata]
        # @return [Hash] hash containing the publishing info ready to be JSONified
        def map_metadata(hyacinth_metadata, target_url)
          datacite_data = {}
          return unless hyacinth_metadata
          # TODO: come up with other/better default value, if needed
          datacite_data[:title] = hyacinth_metadata.title || 'Placeholder Title'
          datacite_data[:creators] = hyacinth_metadata.creators || 'Placeholder Creator'
          datacite_data[:resource_type_general] = hyacinth_metadata.type_of_resource || "Text"
          datacite_data[:url] = target_url || 'https://library.columbia.edu'
          datacite_data.merge!(map_publication_metadata(hyacinth_metadata))
        end

        # @param hyacinth_metadata [HyacinthMetadata]
        # @return [Hash] hash containing the publishing info ready to be JSONified
        def map_publication_metadata(hyacinth_metadata)
          publication_data = {}
          # TODO: come up with other/better default value, if needed
          publication_data[:publisher] = hyacinth_metadata.publisher || "Placeholder Publisher"
          publication_data[:publication_year] = hyacinth_metadata.date_issued_start_year.to_i ||
                                                Time.zone.today.year
          publication_data
        end

        # Returns true if an identifier exists in the external management system
        def exists?(doi)
          rest_api = Datacite::RestApi::V2::Api.new(@rest_api, @user, @password)
          resp = rest_api.get_dois(doi)
          rest_api.parse_doi_from_api_response_body(resp.body).present?
        end

        # @param id [String]
        # @param digital_object [DigitalObject]
        # @param location_uri [String]
        # @param doi_state [Symbol] doi_state can be set to one of the following: :draft, :findable, :registered
        # @return [Boolean] true if update was successful, false otherwise
        def update_impl(doi, digital_object:, location_uri:, doi_state: nil, **_args)
          datacite_data = Datacite::RestApi::V2::Data.new(@prefix)
          datacite_data.update_properties(map_metadata(HyacinthMetadata.new(digital_object.as_json), location_uri))
          datacite_data.build_properties_update(doi_state)
          rest_api = Datacite::RestApi::V2::Api.new(@rest_api, @user, @password)
          rest_api_response = rest_api.put_dois(doi, datacite_data.generate_json_payload)
          unless rest_api_response.status.eql? 200
            Rails.logger.error "Did not update a DOI! Response Code: #{rest_api_response.status}." \
                               "Response Body: #{rest_api_response.body}."
            return false
          end
          true
        end

        def tombstone_impl(_id)
          # TODO: See HYACINTH-876
        end
      end
    end
  end
end
