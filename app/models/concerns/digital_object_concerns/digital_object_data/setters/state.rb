# frozen_string_literal: true

module DigitalObjectConcerns
  module DigitalObjectData::Setters
    module State
      extend ActiveSupport::Concern

      def set_state(digital_object_data)
        return unless digital_object_data.key?('state')
        self.state = digital_object_data['state']
      end
    end
  end
end
