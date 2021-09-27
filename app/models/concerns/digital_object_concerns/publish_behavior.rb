# frozen_string_literal: true
require 'concurrent'

module DigitalObjectConcerns
  module PublishBehavior
    extend ActiveSupport::Concern

    PUBLISH_TIMEOUT = 15 # seconds

    def publish_to(targets: [], publishing_user: nil)
      perform_publish_changes(publish_to: targets, publishing_user: publishing_user)
    end

    def unpublish_from(targets: [])
      perform_publish_changes(unpublish_from: targets, publishing_user: publishing_user)
    end

    def perform_publish_changes(publish_to: [], unpublish_from: [], publishing_user: nil)
      # No one should be publishing an object that has errors
      raise Hyacinth::Exceptions::InvalidPublishConditions, 'Cannot publish a DigitalObject that has errors' if self.errors.present?

      return true if publish_to.blank? && unpublish_from.blank?

      Hyacinth::Config.lock_adapter.with_lock(self.uid) do |lock_object|
        # Use one DateTime to sync publish time to multiple publish targets
        publish_time = DateTime.current

        # If a publish target appears in both publish_to and unpublish_from,
        # we'll treat this kind of duplication as something that should just be cancelled out
        # (as if neither of the values were present in either list).
        (publish_to & unpublish_from).tap do |negated_publish_targets|
          publish_to.reject! { |pub_tar| negated_publish_targets.include?(pub_tar) }
          unpublish_from.reject! { |pub_tar| negated_publish_targets.include?(pub_tar) }
        end

        # Let's run the publish and unpublish operations in parallel to reduce the wait time!
        publish_promises = publish_to.map do |publish_target_to_publish_to|
          async_publish { perform_publish(publish_target_to_publish_to, publish_time, publishing_user) }
        end
        unpublish_promises = unpublish_from.map do |publish_target_to_unpublish_from|
          async_unpublish { perform_unpublish(publish_target_to_unpublish_from) }
        end

        begin
          # Wait for all promises to complete
          promises = publish_promises + unpublish_promises
          Timeout.timeout([PUBLISH_TIMEOUT, lock_object.remaining_lock_time].min) do
            sleep 0.5 while promises.detect(&:incomplete?)
          end

          new_publish_entries = []
          successful_publish_targets = []
          successful_unpublish_targets = []
          publish_failure_messages = []
          unpublish_failure_messages = []

          publish_promises.each do |publish_promise|
            if publish_promise.fulfilled?
              new_publish_entries << publish_promise.value
              successful_publish_targets << publish_promise.value.publish_target
            else
              publish_failure_messages << publish_promise.reason.message
            end
          end

          unpublish_promises.each do |unpublish_promise|
            if unpublish_promise.fulfilled?
              successful_unpublish_targets << unpublish_promise.value
            else
              unpublish_failure_messages << unpublish_promise.reason.message
            end
          end

          current_publish_targets = self.publish_entries.map(&:publish_target)
          current_primary_doi_publish_target = find_highest_priority_doi_eligible_publish_target(current_publish_targets)
          new_highest_priority_doi_eligible_publish_target = find_highest_priority_doi_eligible_publish_target((self.publish_targets - successful_unpublish_targets) + successful_publish_targets)

          ActiveRecord::Base.transaction do
            # Remove entries associated with successfull unpublishes AND successful publishes.
            # For successful publishes that need time/user updates, it's easier to do a mass deletion
            # than to find and update specific ones.
            self.publish_entries.destroy_by(publish_target: successful_publish_targets + successful_unpublish_targets)

            # Clear out the citation_location value for any new entry that isn't the highest priority one
            new_publish_entries.map do |publish_entry|
              publish_entry.citation_location = nil unless publish_entry.publish_target == new_highest_priority_doi_eligible_publish_target
            end

            # Add new entries for successful publish operations
            if new_publish_entries.present?
              if self.first_published_at.blank?
                self.first_published_at = publish_time
                lock_object.unlock && self.save
              end

              self.publish_entries << new_publish_entries
            end
          end

          if new_highest_priority_doi_eligible_publish_target.nil?
            Hyacinth::Config.external_identifier_adapter.tombstone(self.doi)
          elsif (new_highest_priority_doi_eligible_publish_target != current_primary_doi_publish_target) || publish_to.include?(new_highest_priority_doi_eligible_publish_target)
            # We only need to perform an external identifier update if:
            # - We now have a new highest-priority doi publish target
            # or
            # - We are re-publishing to the existing highest-priority doi publish target.
            Hyacinth::Config.external_identifier_adapter.update(self.doi, digital_object: self, location_uri: self.citation_location)
          end

          # Gather error messages
          publish_failure_messages.each do |message|
            self.errors.add(:publish, message)
          end
          unpublish_failure_messages.each do |message|
            self.errors.add(:unpublish, message)
          end

          # Index the DigitalObject after all changes have gone through
          # so that solr publish target info is up to date.
          self.index
        rescue Timeout::Error
          self.errors.add(:publish, 'Request timed out during publish/unpublish and the operation may not have finished. Please try publishing or unpublishing again.')
        end
      end

      self.errors.blank?
    end

    # Returns the current citation location for this DigitalObject, derived from its
    # publish entries, or nil if none of the publish entries have a citation location.
    def citation_location
      self.publish_entries.to_a.find { |publish_entry| publish_entry.citation_location.present? }&.citation_location
    end

    # Republishes to all current publish targets.
    # Returns true on success, false on failure.
    def republish
      return true if self.publish_targets.blank?
      publish(publish_to: self.publish_targets)
    end

    # Unpublishes from all current publish targets.
    # Returns true on success, false on failure.
    def unpublish_from_all
      return true if self.publish_targets.blank?
      unpublish_from(targets: self.publish_targets)
    end

    private

      def async_publish(&block)
        Concurrent::Promise.execute(&block)
      end

      def async_unpublish(&block)
        Concurrent::Promise.execute(&block)
      end

      def perform_publish(publish_target, published_at, published_by)
        publish_result, messages = Hyacinth::Config.publication_adapter.publish(publish_target, self)

        # if result was true, messages array should be the published url
        return PublishEntry.new(publish_target: publish_target, citation_location: messages.first, published_at: published_at, published_by: published_by) if publish_result

        Rails.logger.error("Failed to publish #{self.uid} to #{publish_target.string_key} due to the following errors: #{messages.join(', ')}")
        raise Hyacinth::Exceptions::PublishFailure, "Failed to publish to #{publish_target.string_key}. See error log for details."
      end

      def perform_unpublish(publish_target)
        publish_result, messages = Hyacinth::Config.publication_adapter.publish(publish_target, self)
        return publish_target if publish_result

        Rails.logger.error("Failed to unpublish #{self.uid} from #{publish_target.string_key} due to the following errors: #{messages.join(', ')}")
        raise Hyacinth::Exceptions::PublishFailure, "Failed to unpublish from #{publish_target.string_key}. See error log for details."
      end

      # Given a list of publish targets, returns the publish target with the highest
      # doi priority, ignoring any publish targets that have an is_valid_doi_location value of false.
      # @param publish_targets [Array] An array of publish targets.
      # @return [PublishTarget] The highest priority publish target, or nil if none of the publish
      # targets are doi-eligible.
      def find_highest_priority_doi_eligible_publish_target(publish_targets)
        publish_targets.select(&:valid_doi_location?).max_by(&:doi_priority)
      end
  end
end
