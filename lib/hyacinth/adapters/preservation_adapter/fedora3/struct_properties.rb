module Hyacinth
  module Adapters
    module PreservationAdapter
      class Fedora3::StructProperties
        include Fedora3::TitleHelpers
        include Fedora3::DatastreamMethods

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
