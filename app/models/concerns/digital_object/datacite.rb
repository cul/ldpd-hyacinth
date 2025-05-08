module DigitalObject::Datacite
  extend ActiveSupport::Concern
  # returns the DataCite DOI identifier string (with includes 'doi:' substring in front of actual DOI),
  def mint_and_store_doi(identifier_status, target_url = nil)
    ## Skip if item already has a DOI
    raise Hyacinth::Exceptions::DoiExists, "DOI already exists, minting aborted" if @doi.present?

    if identifier_status == Hyacinth::Datacite::Doi::IDENTIFIER_STATUS[:draft]
      # Reserved DOI are not required to have datacite metadata.
      metadata = {}
    else
      # get the metadata from hyacinth
      hyacinth_metadata = Hyacinth::Datacite::HyacinthMetadata.new as_json
      # Prepare the metadata into an acceptable hash format for DataCite REST API
      # This hash will be JSON'ifed in ApiSession#call_api
      datacite_metadata = Hyacinth::Datacite::DataciteMetadataBuilder.new hyacinth_metadata
      metadata = datacite_metadata.datacite_attributes
    end
    # setup DataCite REST API info: credentials, url, etc.
    datacite_rest_api_session = Hyacinth::Datacite::ApiSession.new(DATACITE[:user], DATACITE[:password])
    # mint_identifier returns a Hyacinth::Datacite::Doi
    # calling code will handle any exception thrown by datacite_rest_api_session.mint_identifier
    datacite_doi_instance = datacite_rest_api_session.mint_identifier(DATACITE[:prefix],
                                                                      identifier_status,
                                                                      target_url,
                                                                      metadata)
    @doi = datacite_doi_instance.identifier
  end

  # Following method will make a request to the DataCite REST API
  # to change the DOI status to 'registered'
  # returns true if status change was successful
  def change_doi_status_to_unavailable
    raise Hyacinth::Exceptions::MissingDoi, "Cannot change status of doi because doi is not present on digital object." if @doi.nil?
    # get the metadata from hyacinth
    hyacinth_metadata = Hyacinth::Datacite::HyacinthMetadata.new as_json
    # Prepare the metadata into an acceptable hash format for DataCite REST API
    # This hash will be JSON'ifed in ApiSession#call_api
    datacite_metadata = Hyacinth::Datacite::DataciteMetadataBuilder.new hyacinth_metadata
    # setup DataCite REST API info: credentials, url, etc.
    datacite_rest_api_session = Hyacinth::Datacite::ApiSession.new(DATACITE[:user], DATACITE[:password])
    # ApiSession#modify_identifier returns true if the response from the DataCite server indicated
    # success, else it returns false
    # fcd1, 12/21/21: @doi is in the EZID format, which includes the 'doi:' substring in front of the
    # actual DOI. So need to clean that up
    doi = @doi.sub('doi:', '')
    # calling code will handle any exception thrown by datacite_rest_api_session.modify_identifier
    datacite_rest_api_session.modify_identifier(doi,
                                                Hyacinth::Datacite::Doi::IDENTIFIER_STATUS[:registered],
                                                datacite_metadata.datacite_attributes)
  end

  # Following method will make a request to the DataCite REST API to update the metadata associated with
  # the DataCite DOI on the server. If supplied, the target URL will also be updated.
  # Uses the modify identifier API call, returns true if metadata update was successful
  def update_doi_metadata(target_url = nil)
    raise Hyacinth::Exceptions::MissingDoi, "Cannot update metadata of doi because doi is not present on digital object." if @doi.nil?
    # get the metadata from hyacinth
    hyacinth_metadata = Hyacinth::Datacite::HyacinthMetadata.new as_json
    # Prepare the metadata into an acceptable hash format for DataCite REST API
    # This hash will be JSON'ifed in ApiSession#call_api
    datacite_metadata = Hyacinth::Datacite::DataciteMetadataBuilder.new hyacinth_metadata
    # setup DataCite REST API info: credentials, url, etc.
    datacite_rest_api_session = Hyacinth::Datacite::ApiSession.new(DATACITE[:user], DATACITE[:password])
    # ApiSession#modify_identifier returns true if the response from the DataCite server indicated
    # success, else it returns false
    # fcd1, 12/21/21: @doi is in the EZID format, which includes the 'doi:' substring in front of the
    # actual DOI. So need to clean that up
    doi = @doi.sub('doi:', '')
    # calling code will handle any exception thrown by datacite_rest_api_session.modify_identifier
    if target_url.nil?
      datacite_rest_api_session.modify_identifier(doi,
                                                  Hyacinth::Datacite::Doi::IDENTIFIER_STATUS[:findable],
                                                  datacite_metadata.datacite_attributes)
    else
      datacite_rest_api_session.modify_identifier(doi,
                                                  Hyacinth::Datacite::Doi::IDENTIFIER_STATUS[:findable],
                                                  datacite_metadata.datacite_attributes,
                                                  target_url)
    end
  end

  # fcd1, 12/18/21: Following is only called with the publish.rake task
  # Following method will make a request to the DataCite REST API to update the target URL associated
  # with the DataCite DOI on the server.
  # Note that for DataCite DOIs that are in the findable state, a target URL is required.
  # Uses the modify identifier API call, returns true if metadata update was successful
  def update_doi_target_url(target_url)
    raise Hyacinth::Exceptions::MissingDoi, "Cannot update metadata of doi because doi is not present on digital object." if @doi.nil?
    # setup DataCite REST API info: credentials, url, etc.
    datacite_rest_api_session = Hyacinth::Datacite::ApiSession.new(DATACITE[:user], DATACITE[:password])
    # ApiSession#modify_identifier returns true if the response from the DataCite server indicated
    # success, else it returns false
    # fcd1, 12/21/21: @doi is in the EZID format, which includes the 'doi:' substring in front of the
    # actual DOI. So need to clean that up
    doi = @doi.sub('doi:', '')
    # calling code will handle any exception thrown by datacite_rest_api_session.modify_identifier
    datacite_rest_api_session.modify_identifier(doi,
                                                Hyacinth::Datacite::Doi::IDENTIFIER_STATUS[:findable],
                                                target_url)
  end
end
