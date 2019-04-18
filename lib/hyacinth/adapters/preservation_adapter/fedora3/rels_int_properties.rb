module Hyacinth
  module Adapters
    module PreservationAdapter
      class Fedora3::RelsIntProperties
        module URIS
          EXTENT = "http://purl.org/dc/terms/extent".freeze
          HAS_MESSAGE_DIGEST = "http://www.loc.gov/premis/rdf/v1#hasMessageDigest".freeze
        end

        def self.from(hyacinth_obj)
          new(hyacinth_obj)
        end

        def initialize(hyacinth_obj)
          @hyacinth_obj = hyacinth_obj
        end

        def to(fedora_obj)
          # TODO
        end
      end
    end
  end
end
