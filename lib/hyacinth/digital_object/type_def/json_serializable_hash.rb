# TODO: Delete if not used
module Hyacinth
  module DigitalObject
    module TypeDef
      class JsonSerializableHash < Hyacinth::DigitalObject::TypeDef::JsonSerializableBase
        def initialize
          super(::Hash)
        end
      end
    end
  end
end
