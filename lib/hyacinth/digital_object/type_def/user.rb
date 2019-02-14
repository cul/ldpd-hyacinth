module Hyacinth
  module DigitalObject
    module TypeDef
      class User < Hyacinth::DigitalObject::TypeDef::Base
        def initialize
          super(::User)
        end
      end
    end
  end
end
