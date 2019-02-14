module Hyacinth
  module DigitalObject
    module TypeDef
      class Integer < Hyacinth::DigitalObject::TypeDef::Base
        def initialize
          super(::Integer)
        end
      end
    end
  end
end
