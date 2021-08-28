# frozen_string_literal: true

module DigitalObjectConcerns
  module AttributeAssignment
    module Title
      extend ActiveSupport::Concern

      def assign_title(digital_object_data)
        return unless digital_object_data.key?('title')
        self.title = digital_object_data['title']
      end
    end
  end
end
