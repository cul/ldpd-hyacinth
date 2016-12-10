module DigitalObject::Ezid
  extend ActiveSupport::Concern
  # fcd1, 11/16/16: the signature of mint_and_store_doi assumes that the shoulder will be the same for
  # all minted EZID DOIs, so it is not passed via an argument but read straight from the EZID hash (populated
  # via ezid.yml).
  # returns the EZID DOI identifier string, or nil if minting did not go through
  def mint_and_store_doi(identifier_status,
                         target_url = nil)
    # get the metadata from hyacinth
    hyacinth_metadata = Hyacinth::Ezid::HyacinthMetadata.new @digital_object_data
    # prepare the metadata into an acceptable format for EZID
    datacite_metadata = Hyacinth::Ezid::DataciteMetadataBuilder.new hyacinth_metadata
    # setup EZID API info: credentials, url, etc.
    ezid_api_session = Hyacinth::Ezid::ApiSession.new(EZID[:user], EZID[:password])
    # mint_identifier returns a Hyacinth::Ezid::Doi
    ezid_doi_instance = ezid_api_session.mint_identifier(EZID[:shoulder][:doi],
                                                         identifier_status,
                                                         target_url,
                                                         datacite: datacite_metadata.datacite_xml)
    # if above method returned nil, call to EZID API was unsuccessful. Return nil to indicate failure
    # if unsuccessful because of timeout, log faiilure and return nil
    if ezid_api_session.timed_out?
      Hyacinth::Utils::Logger.logger.info("#mint_and_store_doi: EZID API call to mint_identifier timed-out.")
      return nil
    end
    # if got a response from EZID server indicating failure, log info and return nil
    if ezid_doi_instance.nil?
      response = ezid_api_session.last_response_from_server
      Hyacinth::Utils::Logger.logger.info("#mint_and_store_doi: EZID API call to mint_identifier was unsuccessful.")
      Hyacinth::Utils::Logger.logger.info("#mint_and_store_doi: Response from EZID server follows:\n" \
                                          "HTTP satus code: #{response.http_status_code}\n" \
                                          "HTTP server message: #{response.http_server_message}\n" \
                                          "response body: #{response.body}") unless response.nil?
      return nil
    end
    @ezid_doi = ezid_doi_instance.identifier
    # store the EZID DOI identifier in RELS-EXT of fedora object
    @fedora_object.add_relationship(:ezid_doi, ezid_doi_instance.identifier)
    @ezid_doi
  end

  # Following method will make a request to the EZID server to change the
  # EZID DOI status to 'unavailable'
  # See http://ezid.cdlib.org/doc/apidoc.html#identifier-status
  # returns true if status change was successful
  # if not, returns false
  def change_doi_status_to_unavailable
    return false if @ezid_doi.nil?
    ezid_api_session = Hyacinth::Ezid::ApiSession.new(EZID[:user], EZID[:password])
    # ApiSession#modify_identifier returns true if the response from the EZID server indicated
    # success, else it returns false
    ezid_api_session.modify_identifier(@ezid_doi,
                                       _status: Hyacinth::Ezid::Doi::IDENTIFIER_STATUS[:unavailable])
  end

  # Following method will make a request to the EZID server to update the metadata associated with
  # the EZID DOI entry on the server. Uses the modify identifier API call
  # returns true if metadata update was successful
  # if not, returns false
  def update_doi_metadata
    return false if @ezid_doi.nil?
    # get the metadata from hyacinth
    hyacinth_metadata = Hyacinth::Ezid::HyacinthMetadata.new @digital_object_data
    # prepare the metadata into an acceptable format for EZID
    datacite_metadata = Hyacinth::Ezid::DataciteMetadataBuilder.new hyacinth_metadata
    # setup EZID API info: credentials, url, etc.
    ezid_api_session = Hyacinth::Ezid::ApiSession.new(EZID[:user], EZID[:password])
    # ApiSession#modify_identifier returns true if the response from the EZID server indicated
    # success, else it returns false
    ezid_api_session.modify_identifier(@ezid_doi,
                                       datacite: datacite_metadata.datacite_xml,
                                       _status: Hyacinth::Ezid::Doi::IDENTIFIER_STATUS[:public])
  end
end
