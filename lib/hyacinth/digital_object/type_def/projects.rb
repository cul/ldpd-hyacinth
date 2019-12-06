# frozen_string_literal: true

module Hyacinth
  module DigitalObject
    module TypeDef
      class Projects < Hyacinth::DigitalObject::TypeDef::JsonSerializableSet
        def initialize
          super(Hyacinth::DigitalObject::TypeDef::Project)
        end
      end
    end
  end
end
