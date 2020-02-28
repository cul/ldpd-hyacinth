# frozen_string_literal: true

module DigitalObjectConcerns
  module AttributeAssignment
    module Preserve
      extend ActiveSupport::Concern

      def assign_preserve(digital_object_data)
        return unless digital_object_data.key?('preserve')
        @preserve = digital_object_data['preserve'].to_s.casecmp('true').zero?
      end
    end
  end
end
