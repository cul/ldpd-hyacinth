# frozen_string_literal: true

module Hyacinth
  module DigitalObject
    module TypeDef
      class Uri < Hyacinth::DigitalObject::TypeDef::String
        def initialize
          super
          validation(method(:validate_uri).to_proc)
        end

        def validate_uri(value)
          URI(value).scheme.present?
        end

        class Http < Uri
          def validate_uri(value)
            uri = URI(value)
            (uri.scheme =~ /https?/).present? && uri.host.present?
          end
        end
      end
    end
  end
end
