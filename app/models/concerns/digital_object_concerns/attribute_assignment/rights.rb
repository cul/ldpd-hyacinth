# frozen_string_literal: true

module DigitalObjectConcerns
  module AttributeAssignment
    module Rights
      extend ActiveSupport::Concern

      def assign_rights(digital_object_data, merge_rights = true)
        return unless digital_object_data.key?('rights')
        # TODO: We need to add some kind of validation here, or potentially
        # store the rights config info on the server side and then pass it
        # to the client side when rendering the rights editing form.
        # See: HYACINTH-429
        new_rights = digital_object_data['rights']

        if merge_rights
          rights.merge!(new_rights)
        else
          self.rights = new_rights
        end
      end

      # Trims whitespace and removes blank fields from descriptive metadata.
      def clean_rights!
        descriptive_metadata.deep_stringify_keys!
        Hyacinth::Utils::Clean.trim_whitespace!(rights)
        Hyacinth::Utils::Clean.remove_blank_fields!(rights)
      end
    end
  end
end
