# frozen_string_literal: true

module Hyacinth
  module Adapters
    module ExternalIdentifierAdapter
      class Datacite < Abstract
        DOI_STATES = [:draft, :findable, :registered].freeze

        # https://schema.datacite.org/meta/kernel-4.4/doc/DataCite-MetadataKernel_v4.4.pdf
        REQUIRED_DATACITE_METADATA_PROPERTIES = [:creators,
                                                 :publisher,
                                                 :publication_year,
                                                 :resource_type_general,
                                                 :title,
                                                 :url].freeze

        # https://schema.datacite.org/meta/kernel-4.4/doc/DataCite-MetadataKernel_v4.4.pdf
        SUPPORTED_DATACITE_METADATA_PROPERTIES = [:subject,
                                                  :stuff].concat(REQUIRED_DATACITE_METADATA_PROPERTIES).freeze
        attr_reader :rest_api

        def initialize(adapter_config = {})
          super(adapter_config)
        end

        # @param id [String]
        # @return [Boolean] true if this adapteppr can handle this type of identifier
        def handles?(id)
          id =~ /^10\.[A-Za-z0-9]+\/[A-Za-z0-9\-]+/
        end

        # metadata is not required when minting a draft DOI.
        # metadata is required when minting a findable DOI. This metadata must include all the
        # properties required by DataCite.
        # It is also possible to specify a (non-existent) DOI when minting. However, this is not
        # currently supported in the code.
        def mint(hyacinth_metadata = nil, # Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite::Metadata
                 target_url = nil, doi_state = :draft, _doi = nil)
          if doi_state != :draft && hyacinth_metadata.nil?
            Rails.logger.error "Hyacinth metadata required to mint DOI in #{doi_state} state"
            return
          end
          datacite_data = Datacite::RestApi::V2::Data.new
          datacite_data.prefix = DATACITE[:prefix]
          map_metadata(hyacinth_metadata, datacite_data, target_url) if hyacinth_metadata
          datacite_data.build_mint(doi_state, hyacinth_metadata.present?)
          rest_api = Datacite::RestApi::V2::Api.new(DATACITE[:rest_api], DATACITE[:user], DATACITE[:password])
          rest_api_response = rest_api.post_dois datacite_data.generate_json_payload
          unless rest_api_response.status.eql? 201
            Rails.logger.error "Did not mint a DOI! Response Code: #{rest_api_response.status}." \
                               "Response Body: #{rest_api_response.body}." \
                               "Request Body: #{rest_api.most_recent_request_body}"
            return
          end
          rest_api.parse_doi_from_api_response_body(rest_api_response.body)
        end

        # return nil if unsuccessful, else returns the response body
        def update_doi(doi,
                       hyacinth_metadata, # Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite::Metadata
                       target_url, doi_state = nil)
          datacite_data = Datacite::RestApi::V2::Data.new
          datacite_data.prefix = DATACITE[:prefix]
          map_metadata(hyacinth_metadata, datacite_data, target_url)
          datacite_data.build_properties_update(doi_state)
          rest_api = Datacite::RestApi::V2::Api.new(DATACITE[:rest_api], DATACITE[:user], DATACITE[:password])
          rest_api_response = rest_api.put_dois(doi, datacite_data.generate_json_payload)
          unless rest_api_response.status.eql? 200
            Rails.logger.error "Did not update a DOI! Response Code: #{rest_api_response.status}." \
                               "Response Body: #{rest_api_response.body}." \
                               "Request Body: #{rest_api.most_recent_request_body}"
            return
          end
          rest_api_response.body
        end

        # Following only updates the target url. Assumes the other required DataCite properties
        # are already set. If not sure, use update_doi(doi, hyacinth_metadata, target_url, doi_state = nil)
        # and supply required metadata
        # return nil if unsuccessful, else returns the response body
        def update_doi_target_url(doi, target_url)
          datacite_data = Datacite::RestApi::V2::Data.new
          datacite_data.prefix = DATACITE[:prefix]
          datacite_data.url = target_url
          datacite_data.build_properties_update
          rest_api = Datacite::RestApi::V2::Api.new(DATACITE[:rest_api], DATACITE[:user], DATACITE[:password])
          rest_api_response = rest_api.put_dois(doi, datacite_data.generate_json_payload)
          unless rest_api_response.status.eql? 200
            Rails.logger.error "Did not mint a DOI! Response Code: #{rest_api_response.status}." \
                               "Response Body: #{rest_api_response.body}." \
                               "Request Body: #{rest_api.most_recent_request_body}"
            return
          end
          rest_api_response.body
        end

        def map_metadata(hyacinth_metadata, datacite_data, target_url)
          return unless hyacinth_metadata
          # BEGIN metadata required by DataCite
          # Of course, we can come up with other/better default values
          datacite_data.title = hyacinth_metadata.title || 'Placeholder Title'
          datacite_data.creators = hyacinth_metadata.creators || 'Placeholder Creator'
          map_publication_metadata(hyacinth_metadata, datacite_data)
          datacite_data.resource_type_general = hyacinth_metadata.type_of_resource || "Text"
          datacite_data.url = target_url || 'https://library.columbia.edu'
          # END metadata required by DataCite
        end

        def map_publication_metadata(hyacinth_metadata, datacite_data)
          datacite_data.publisher = hyacinth_metadata.publisher || "Placeholder Publisher"
          datacite_data.publication_year = hyacinth_metadata.date_issued_start_year.to_i ||
                                           "Placeholder Publication Year"
        end

        # Returns true if an identifier exists in the external management system
        def exists?(doi)
          rest_api = Datacite::RestApi::V2::Api.new(DATACITE[:rest_api], DATACITE[:user], DATACITE[:password])
          resp = rest_api.get_dois(doi)
          rest_api.parse_doi_from_api_response_body(resp.body).present?
        end

        # @param id [String]
        # @param digital_object [DigitalObject]
        # @param location_uri [String]
        # @return [Boolean] true if this adapter can handle this type of identifier
        def update_impl(_id, _digital_object, _location_uri)
          # needs state as a parameter in order to be able to update DOI state
          # also, prefer a Metadata as an argument instead of a Digital Object. Metadata offers "accessors" to
          # get to metadata inside Digital Object
          raise NotImplementedError
        end

        def tombstone_impl(_id)
          # switch state to registered?
          raise NotImplementedError
        end
      end
    end
  end
end
