module Hyacinth
  module Adapters
    module ExternalIdentifierAdapter
      class Datacite < Abstract
        IDENTIFIER_STATUS = { public: 'public',
                              reserved: 'reserved',
                              unavailable: 'unavailable' }.freeze
        def initialize(adapter_config = {})
          super(adapter_config)
        end

        # @param id [String]
        # @return [Boolean] true if this adapter can handle this type of identifier
        def handles?(id)
          id =~ /^10\.[A-Za-z0-9]+\/[A-Za-z0-9\-]+/
        end

        # Generates a new persistent id, ensuring that nothing currently uses that identifier.
        # @return [String] a new id
        def mint
          # metadata is blank when minting
          # TODO: allow existing object data to be pushed on mint
          metadata = {}
          # target is blank when minting
          # TODO: allow existing object data to be pushed on mint
          target_url = nil
          # status is reserved when minting
          # TODO: allow provided target
          identifier_status = IDENTIFIER_STATUS[:reserved]
          # mint_identifier returns a Hyacinth::Ezid::Doi
          ezid_doi_instance = api_session.mint_identifier(DATACITE[:shoulder][:doi], identifier_status, target_url, metadata)
          # if above method returned nil, call to EZID API was unsuccessful. Return nil to indicate failure
          # if unsuccessful because of timeout, log faiilure and return nil
          if api_session.timed_out?
            log(:error, "#mint_and_store_doi: EZID API call to mint_identifier timed-out.")
            return nil
          end
          # if got a response from EZID server indicating failure, log info and return nil
          if ezid_doi_instance.nil?
            response = api_session.last_response_from_server
            log(:error, "#mint_and_store_doi: EZID API call to mint_identifier was unsuccessful.")
            log(:error, "#mint_and_store_doi: Response from EZID server follows:\n#{http_error_message(response)}")
            return nil
          end
          ezid_doi_instance.identifier.sub(/^doi\:/, '')
        end

        # Returns true if an identifier exists in the external management system
        def exists?(_id)
          raise NotImplementedError
        end

        # @param id [String]
        # @param digital_object [DigitalObject::Base]
        # @param location_uri [String]
        # @return [Boolean] true if this adapter can handle this type of identifier
        def update_impl(id, digital_object, location_uri)
          return update_doi_target_url(id, location_uri) if digital_object.blank?

          # get the metadata from hyacinth
          hyacinth_metadata = Datacite::Metadata.new digital_object.as_json
          # prepare the metadata into an acceptable format for EZID
          datacite_metadata = Datacite::MetadataBuilder.new hyacinth_metadata
          # ApiSession#modify_identifier returns true if the response from the EZID server indicated
          # success, else it returns false
          opts = { datacite: datacite_metadata.datacite_xml, _status: IDENTIFIER_STATUS[:public] }
          opts[:_target] = location_uri unless location_uri.blank?
          api_session.modify_identifier(id, opts)
        end

        # Following method will make a request to the EZID server to update the target URL associated
        # with the EZID DOI entry on the server.
        # (See _target in http://ezid.cdlib.org/doc/apidoc.html#internal-metadata)
        # To delete the target URL stored in the DOI server, use an empty string as the argument.
        # Uses the modify identifier API call, returns true if metadata update was successful
        # if not, returns false
        def update_doi_target_url(doi, target_url)
          return false if doi.nil?
          return false if target_url.nil?
          # ApiSession#modify_identifier returns true if the response from the EZID server indicated
          # success, else it returns false
          api_session.modify_identifier(doi, _target: target_url, _status: IDENTIFIER_STATUS[:public])
        end

        def tombstone_impl(id)
          return false if id.nil?
          # ApiSession#modify_identifier returns true if the response from the EZID server indicated
          # success, else it returns false
          api_session.modify_identifier(id, _status: IDENTIFIER_STATUS[:unavailable])
        end

        private

          # setup EZID API info: credentials, url, etc.
          def api_session
            Thread.current[:datacite_ezid_api_session] ||= Datacite::EzidSession.new(DATACITE[:user], DATACITE[:password])
          end

          def http_error_message(response)
            return "" if response.nil?
            "HTTP status code: #{response.http_status_code}\n" \
            "HTTP server message: #{response.http_server_message}\n" \
            "response body: #{response.body}"
          end

          # TODO: Remove this method when there's a general logging proxy
          def log(status, message); end
      end
    end
  end
end
