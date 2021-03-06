# frozen_string_literal: true

module DigitalObjectConcerns
  module AttributeAssignment
    module OptimisticLockToken
      extend ActiveSupport::Concern

      def assign_optimistic_lock_token(digital_object_data)
        return unless digital_object_data.key?('optimistic_lock_token')
        self.optimistic_lock_token = digital_object_data['optimistic_lock_token']
      end
    end
  end
end
