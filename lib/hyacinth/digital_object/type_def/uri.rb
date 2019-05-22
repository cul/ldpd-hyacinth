module Hyacinth
  module DigitalObject
    module TypeDef
      class URI < Hyacinth::DigitalObject::TypeDef::String
        def initialize
          super
          validation(method(:validate_uri).to_proc)
        end

        def validate_uri(value)
          URI(value).scheme.present?
        end

        class HTTP < URI
          def validate_uri(value)
            uri = URI(value)
            (uri.scheme =~ /https?/).present? && uri.host.present?
          end
        end
      end
    end
  end
end
