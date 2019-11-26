# frozen_string_literal: true

module Hyacinth
  module DigitalObject
    module TypeDef
      class Boolean < Hyacinth::DigitalObject::TypeDef::JsonSerializableBase
        def initialize
          super
          default(proc { false })
          validation(proc { |value| (value == true) || (value == false) })
        end
      end
    end
  end
end
