# frozen_string_literal: true

module DigitalObjectConcerns
  module AttributeAssignment
    module Title
      extend ActiveSupport::Concern

      def assign_title(digital_object_data)
        return unless digital_object_data.key?('title')
        self.title = digital_object_data['title']
      end

      # Trims whitespace and removes blank fields from descriptive_metadata.
      def clean_title!
        return if self.title.blank?
        self.title.deep_stringify_keys!
        Hyacinth::Utils::Clean.trim_whitespace!(self.title)
        Hyacinth::Utils::Clean.remove_blank_fields!(self.title)
      end
    end
  end
end
