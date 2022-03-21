# frozen_string_literal: true

module Hyacinth
  module Adapters
    module PreservationAdapter
      module Fedora3::PropertyContextInitializers
        def self.included(mod)
          mod.extend ClassMethods
        end

        module ClassMethods
          def from(adapter, hyacinth_obj)
            new(adapter, hyacinth_obj)
          end
        end

        def initialize(adapter, hyacinth_obj)
          @adapter = adapter
          @hyacinth_obj = hyacinth_obj
        end

        def adapter
          @adapter
        end
      end
    end
  end
end
