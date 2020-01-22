# frozen_string_literal: true

module DigitalObjectConcerns
  module DigitalObjectData
    module Setters
      module Resources
        extend ActiveSupport::Concern

        def set_resources(digital_object_data)
          return unless digital_object_data.key?('resources')
          # TODO: Implement this
        end
      end
    end
  end
end
