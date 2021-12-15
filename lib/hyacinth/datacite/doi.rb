module Hyacinth::Datacite
  class Doi
    IDENTIFIER_STATUS = { findable: 'findable',
                          draft: 'draft',
                          registered: 'registered' }
    attr_reader :identifier, :metadata
    def initialize(doi_identifier, status = IDENTIFIER_STATUS[:draft], datacite_metadata = {})
      @identifier = doi_identifier
      @datacite_metadata = datacite_metadata
      @status = status
    end
  end
end
