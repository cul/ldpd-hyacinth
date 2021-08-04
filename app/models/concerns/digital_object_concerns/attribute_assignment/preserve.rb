# frozen_string_literal: true

module DigitalObjectConcerns
  module AttributeAssignment
    module Preserve
      extend ActiveSupport::Concern

      def assign_preserve(digital_object_data)
        return unless digital_object_data.key?('preserve')
        @preserve = digital_object_data['preserve'].to_s.casecmp('true').zero?
      end

      def assign_preservation_target_uris(digital_object_data)
        return unless digital_object_data.key?('preservation_target_uris')
        preservation_target_uri_values = digital_object_data['preservation_target_uris'].to_set
        return if preservation_target_uri_values == preservation_target_uris # no-op if same as current uris
        raise Hyacinth::Exceptions::AlreadySet, "Cannot set preservation_target_uris because preservation_target_uris have already been set." if preservation_target_uris.present?
        self.preservation_target_uris.merge(preservation_target_uri_values)
      end
    end
  end
end
