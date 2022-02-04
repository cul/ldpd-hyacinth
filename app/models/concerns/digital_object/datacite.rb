module DigitalObject::Datacite
  extend ActiveSupport::Concern
  # returns the DataCite DOI identifier string (with includes 'doi:' substring in front of actual DOI),
  # or nil if minting did not go through
  def mint_and_store_doi(identifier_status, target_url = nil)
    ## Skip if item already has a DOI
    return nil if @doi.present?

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
    datacite_rest_api_session = Hyacinth::Datacite::ApiSession.new(EZID[:user], EZID[:password])
    # mint_identifier returns a Hyacinth::Datacite::Doi
    datacite_doi_instance = datacite_rest_api_session.mint_identifier(EZID[:prefix],
                                                                      identifier_status,
                                                                      target_url,
                                                                      metadata)
    # if above method returned nil, call to DataCite REST API was unsuccessful. Return nil to indicate failure
    # if unsuccessful because of timeout, log failure and return nil
    if datacite_rest_api_session.timed_out?
      Hyacinth::Utils::Logger.logger.error("#mint_and_store_doi: DataCite REST API call to mint_identifier timed-out.")
      return nil
    end
    # if got a response from DataCite REST API server indicating failure, log info and return nil
    if datacite_doi_instance.nil?
      response = datacite_rest_api_session.last_response_from_server
      Hyacinth::Utils::Logger.logger.error("#mint_and_store_doi: DataCite REST API call to mint_identifier was unsuccessful.")
      Hyacinth::Utils::Logger.logger.error("#mint_and_store_doi: Response from DataCite server follows:\n" \
                                          "HTTP status code: #{response.http_status_code}\n" \
                                          "HTTP server message: #{response.http_server_message}\n" \
                                          "response body: #{response.body}") unless response.nil?
      return nil
    end
    @doi = datacite_doi_instance.identifier
  end

  # Following method will make a request to the DataCite REST API
  # to change the DOI status to 'registered'
  # returns true if status change was successful
  # if not, returns false
  def change_doi_status_to_unavailable
    return false if @doi.nil?
    # get the metadata from hyacinth
    hyacinth_metadata = Hyacinth::Datacite::HyacinthMetadata.new as_json
    # Prepare the metadata into an acceptable hash format for DataCite REST API
    # This hash will be JSON'ifed in ApiSession#call_api
    datacite_metadata = Hyacinth::Datacite::DataciteMetadataBuilder.new hyacinth_metadata
    # setup DataCite REST API info: credentials, url, etc.
    datacite_rest_api_session = Hyacinth::Datacite::ApiSession.new(EZID[:user], EZID[:password])
    # ApiSession#modify_identifier returns true if the response from the DataCite server indicated
    # success, else it returns false
    # fcd1, 12/21/21: @doi is in the EZID format, which includes the 'doi:' substring in front of the
    # actual DOI. So need to clean that up
    doi = @doi.sub('doi:', '')
    datacite_rest_api_session.modify_identifier(doi,
                                                Hyacinth::Datacite::Doi::IDENTIFIER_STATUS[:registered],
                                                datacite_metadata.datacite_attributes)
  end

  # Following method will make a request to the DataCite REST API to update the metadata associated with
  # the DataCite DOI on the server. If supplied, the target URL will also be updated.
  # Uses the modify identifier API call, returns true if metadata update was successful
  # if not, returns false
  def update_doi_metadata(target_url = nil)
    return false if @doi.nil?
    # get the metadata from hyacinth
    hyacinth_metadata = Hyacinth::Datacite::HyacinthMetadata.new as_json
    # Prepare the metadata into an acceptable hash format for DataCite REST API
    # This hash will be JSON'ifed in ApiSession#call_api
    datacite_metadata = Hyacinth::Datacite::DataciteMetadataBuilder.new hyacinth_metadata
    # setup DataCite REST API info: credentials, url, etc.
    datacite_rest_api_session = Hyacinth::Datacite::ApiSession.new(EZID[:user], EZID[:password])
    # ApiSession#modify_identifier returns true if the response from the DataCite server indicated
    # success, else it returns false
    # fcd1, 12/21/21: @doi is in the EZID format, which includes the 'doi:' substring in front of the
    # actual DOI. So need to clean that up
    doi = @doi.sub('doi:', '')
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
  # if not, returns false
  def update_doi_target_url(target_url)
    return false if @doi.nil?
    return false if target_url.nil?
    # setup DataCite REST API info: credentials, url, etc.
    datacite_rest_api_session = Hyacinth::Datacite::ApiSession.new(EZID[:user], EZID[:password])
    # ApiSession#modify_identifier returns true if the response from the DataCite server indicated
    # success, else it returns false
    # fcd1, 12/21/21: @doi is in the EZID format, which includes the 'doi:' substring in front of the
    # actual DOI. So need to clean that up
    doi = @doi.sub('doi:', '')
    datacite_rest_api_session.modify_identifier(doi,
                                                Hyacinth::Datacite::Doi::IDENTIFIER_STATUS[:findable],
                                                target_url)
  end
end
