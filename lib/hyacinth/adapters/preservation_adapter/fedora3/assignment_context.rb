module Hyacinth
  module Adapters
    module PreservationAdapter
      class Fedora3::AssignmentContext
        module Client
          def assign(klass)
            Fedora3::AssignmentContext.new(klass)
          end
        end

        def initialize(klass)
          @property_class = klass
        end

        def to(fedora_obj)
          Deferred.new(@property_class, fedora_obj)
        end

        def from(hyacinth_obj)
          @property_class.new(hyacinth_obj)
        end

        class Deferred
          def initialize(klass, fedora_obj)
            @property_class = klass
            @fedora_obj = fedora_obj
          end

          def from(hyacinth_obj)
            @property_class.new(hyacinth_obj).to(@fedora_obj)
          end
        end
      end
    end
  end
end
