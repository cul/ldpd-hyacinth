# frozen_string_literal: true

module DigitalObjectConcerns
  module DigitalObjectData::Setters
    module Preserve
      extend ActiveSupport::Concern

      def set_preserve(digital_object_data)
        return unless digital_object_data.key?('preserve')
        @preserve = digital_object_data['preserve'].to_s.downcase == 'true'
      end
    end
  end
end
