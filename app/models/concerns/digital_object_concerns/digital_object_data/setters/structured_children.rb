module DigitalObjectConcerns
  module DigitalObjectData::Setters
    module StructuredChildren
      extend ActiveSupport::Concern

      def append_child_uid(uid)
        self.structured_children['structure'] << uid
      end

      # Deletes the given child uid from the list of structured children.
      # If the list of structured children doesn't include the uid, then this is a no-op.
      def remove_child_uid(uid)
        # TODO: If we one day support hierarchical structured children, this logic will need to change
        self.structured_children['structure'].delete(uid)
      end
    end
  end
end
