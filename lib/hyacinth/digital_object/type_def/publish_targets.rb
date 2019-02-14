module Hyacinth
  module DigitalObject
    module TypeDef
      class PublishTargets < Hyacinth::DigitalObject::TypeDef::Base
        def initialize
          super(::Set)
        end
      end
    end
  end
end
