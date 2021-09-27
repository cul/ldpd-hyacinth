# frozen_string_literal: true

module Hyacinth
  module Adapters
    module ExternalIdentifierAdapter
      class Datacite < Abstract
        attr_reader :rest_api

        def initialize(adapter_config = {})
          @rest_api = Datacite::RestApi::V2::Api.new(adapter_config)
          @prefix = adapter_config[:prefix]
          super(adapter_config)
        end

        # @param id [String]
        # @return [Boolean] true if this adapter can handle this type of identifier
        def handles?(id)
          id =~ /^10\.[A-Za-z0-9]+\/[A-Za-z0-9\-]+/
        end

        # digital_object is not required when minting a draft DOI.
        # digital_object is required when minting a findable DOI. This digital_object must
        # include all the metadata properties required by DataCite.
        # It is also possible to specify a (non-existent) DOI when minting. However, this is not
        # currently supported in this implementation.
        # @param digital_object [DigitalObject]
        # @param location_uri [String] the target URL to be associated with the new DOI
        # @param doi_state [Symbol] doi_state can be set to one of the following: :draft, :findable, :registered
        # @return [String] a new id
        def mint(digital_object: nil, location_uri: nil, doi_state: :draft, **_rest)
          if doi_state != :draft && digital_object.nil?
            Rails.logger.error "Hyacinth metadata required to mint DOI in #{doi_state} state"
            return
          end
          datacite_data = Datacite::RestApi::V2::Data.new(@prefix)
          datacite_data.update_properties(HyacinthMetadata.as_datacite_properties(digital_object, location_uri)) if digital_object
          datacite_data.build_mint(doi_state)
          rest_api_response = rest_api.post_dois(datacite_data.generate_json_payload)
          unless rest_api_response.status.eql? 201
            Rails.logger.error "Did not mint a DOI! Response Code: #{rest_api_response.status}." \
                               "Response Body: #{rest_api_response.body}."
            return
          end
          rest_api.parse_doi_from_api_response_body(rest_api_response.body)
        end

        # Returns true if an identifier exists in the external management system
        # @param id [String] a DOI
        def exists?(id)
          resp = rest_api.get_dois(id)
          rest_api.parse_doi_from_api_response_body(resp.body).present?
        end

        # @param id [String] the DOI to update
        # @param digital_object [DigitalObject]
        # @param location_uri [String] the target URL to be associated with the DOI
        # @param doi_state [Symbol] doi_state can be set to one of the following: :draft, :findable, :registered
        # @return [Boolean] true if update was successful, false otherwise
        def update_impl(id, digital_object:, location_uri:, doi_state: nil, **_rest)
          datacite_data = Datacite::RestApi::V2::Data.new(@prefix)
          datacite_data.update_properties(HyacinthMetadata.as_datacite_properties(digital_object, location_uri))
          datacite_data.build_properties_update(doi_state)
          rest_api_response = rest_api.put_dois(id, datacite_data.generate_json_payload)
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
