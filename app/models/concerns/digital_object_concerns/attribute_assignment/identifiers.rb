# frozen_string_literal: true

module DigitalObjectConcerns
  module AttributeAssignment
    module Identifiers
      extend ActiveSupport::Concern

      def assign_identifiers(digital_object_data)
        return unless digital_object_data.key?('identifiers')
        self.identifiers = Set.new(digital_object_data['identifiers'])
      end
    end
  end
end
