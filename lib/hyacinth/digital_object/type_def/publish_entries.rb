# frozen_string_literal: true

module Hyacinth
  module DigitalObject
    module TypeDef
      class PublishEntries < Hyacinth::DigitalObject::TypeDef::JsonSerializableHash
        def initialize
          super(Hyacinth::DigitalObject::TypeDef::PublishEntry)
        end
      end
    end
  end
end
