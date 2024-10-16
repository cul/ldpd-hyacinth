# frozen_string_literal: true

module Hyacinth
  module Adapters
    module ExternalIdentifierAdapter
      class Datacite < Abstract
        attr_reader :rest_api, :datacite_payloads

        def initialize(adapter_config = {})
          @rest_api = Datacite::RestApi::V2::Api.new(**adapter_config)
          @datacite_payloads = Datacite::RestApi::V2::Data.new(**adapter_config)
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
        # @param target_url [String] the target URL to be associated with the new DOI
        # @param publish [Boolean] make the identifier publicly resolvable
        # @return [String] a new id
        def mint_impl(digital_object, target_url, publish = false)
          state = publish ? :findable : :draft

          if state != :draft && digital_object.nil?
            Rails.logger.error "Hyacinth metadata required to mint DOI in #{state} state"
            return
          end
          json_payload = datacite_payloads.build_mint(digital_object, state, target_url)
          rest_api_response = rest_api.create_doi(json_payload)
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
          rest_api.doi_exists?(id)
        end

        # @param id [String] the DOI to update
        # @param digital_object [DigitalObject]
        # @param target_url [String] the target URL to be associated with the DOI
        # @param publish [Boolean] make the identifier publicly resolvable
        # @return [Boolean] true if update was successful, false otherwise
        def update_impl(id, digital_object, target_url, publish = true)
          state = publish ? :findable : :registered
          json_payload = datacite_payloads.build_properties_update(digital_object, state, target_url)
          rest_api_response = rest_api.update_doi(id, json_payload)
          unless rest_api_response.status.eql? 200
            Rails.logger.error "Did not update a DOI! Response Code: #{rest_api_response.status}." \
                               "Response Body: #{rest_api_response.body}."
            return false
          end
          true
        end

        def deactivate_impl(id)
          # if DOI is not findable, there is no work to do here
          return true unless rest_api.doi_findable?(id)
          json_payload = datacite_payloads.build_state_update(:registered)
          rest_api_response = rest_api.update_doi(id, json_payload)
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
