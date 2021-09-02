# frozen_string_literal: true

module ResourceRequestJobs
  module IiifJobBehaviors
    extend ActiveSupport::Concern

    class_methods do
      def src_resource_for_digital_object(digital_object)
        digital_object.asset_type == 'Image' ? digital_object.access_resource : digital_object.poster_resource
      end

      def eligible_object?(digital_object)
        return false unless digital_object&.is_a?(::DigitalObject::Asset)
        if digital_object.asset_type == 'Image'
          digital_object.has_access_resource?
        else
          digital_object.has_poster_resource?
        end
      end
    end
  end
end
