# frozen_string_literal: true

module Hyacinth
  module DigitalObject
    module TypeDef
      class JsonSerializableCollection < Hyacinth::DigitalObject::TypeDef::Base
        def initialize(type = nil)
          super()
          @translator = type.new if type
          raise NotImplementedError, "Cannot instantiate #{self.class}. Instantiate a subclass instead." if self.class == JsonSerializableCollection
        end
      end
    end
  end
end
