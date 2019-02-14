module Hyacinth
  module DigitalObject
    module TypeDef
      class Boolean < Hyacinth::DigitalObject::TypeDef::Base
        def initialize
          super([::TrueClass, ::FalseClass])
          @default_value_proc = -> { boolean } # boolean types should default to false instead of nil
        end
      end
    end
  end
end
