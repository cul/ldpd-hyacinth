module Hyacinth
  module Adapters
    module PreservationAdapter
      class Fedora3::DCProperties
        def self.export(hyacinth_obj)
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
