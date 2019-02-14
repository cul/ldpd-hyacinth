# TODO: Delete if not used
module Hyacinth
  module DigitalObject
    module TypeDef
      class JsonSerializableArray < Hyacinth::DigitalObject::TypeDef::JsonSerializableBase
        def initialize
          super(::Array)
        end
      end
    end
  end
end
