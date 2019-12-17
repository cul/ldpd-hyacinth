# frozen_string_literal: true

module DigitalObjectConcerns
  module DigitalObjectData::Setters
    module Rights
      extend ActiveSupport::Concern

      def set_rights(digital_object_data)
        return unless digital_object_data.key?('rights')
        # TODO: We need to add some kind of validation here, or potentially
        # store the rights config info on the server side and then pass it
        # to the client side when rendering the rights editing form.
        # See: HYACINTH-429
        self.rights = digital_object_data['rights']
      end
    end
  end
end
