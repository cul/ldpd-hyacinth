# frozen_string_literal: true

module DigitalObjectConcerns
  module AttributeAssignment
    module PendingPublishEntries
      extend ActiveSupport::Concern

      def assign_pending_publish_entries(digital_object_data)
        pub_to = []
        unpub_from = []

        if digital_object_data['republish'].to_s == 'true'
          pub_to = publish_entries.keys
          raise ArgumentError, 'Cannot supply republish flag AND supply publish_to/unpublish_from directives.)' if publish_to_or_unpublish_from_values_present?(digital_object_data)
        elsif publish_to_or_unpublish_from_values_present?(digital_object_data)
          pub_to = digital_object_data['publish_to']
          unpub_from = digital_object_data['unpublish_from']
        else
          return
        end

        # Raise error if pub_to and unpub_from have any overlapping values
        raise ArgumentError, 'Cannot include the same publish target in publish_to and unpublish_from' if (pub_to & unpub_from).length.positive?

        pub_to.freeze
        unpub_from.freeze
        self.pending_publish_to = pub_to
        self.pending_unpublish_from = unpub_from
      end

      def publish_to_or_unpublish_from_values_present?(digital_object_data)
        digital_object_data['publish_to'].present? || digital_object_data['unpublish_from'].present?
      end
    end
  end
end
