# frozen_string_literal: true

module DigitalObjectConcerns
  module AttributeAssignment
    module StructuredChildren
      extend ActiveSupport::Concern

      def append_child_uid(uid)
        structured_children['structure'] << uid
      end

      # Deletes the given child uid from the list of structured children.
      # If the list of structured children doesn't include the uid, then this is a no-op.
      def remove_child_uid(uid)
        # TODO: If we one day support hierarchical structured children, this logic will need to change
        structured_children['structure'].delete(uid)
      end

      # Returns a DigitalObject's structured_children data as a flat list of child pids
      def flat_child_uid_set
        set = Set.new
        return set if structured_children.blank?
        return set if structured_children['structure'].blank?

        unless structured_children['type'] == 'sequence'
          raise Hyacinth::Exceptions::UnsupportedType,
                "At the moment, #flat_child_uid_set only supports structures of type 'sequence'. Received unexpected type: #{structured_children['type'].inspect}"
        end

        set.merge(structured_children['structure'])
        set
      end
    end
  end
end
