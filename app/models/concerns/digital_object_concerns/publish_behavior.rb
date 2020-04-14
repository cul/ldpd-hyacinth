# frozen_string_literal: true

module DigitalObjectConcerns
  module PublishBehavior
    extend ActiveSupport::Concern

    # Publishes this object to the publish targets in pending_publish_entries
    # and updates publish_entries to reflect the newly published state.
    # @param opts [Hash] A hash of options. Options include:
    #             :user [User] User who is performing the publish operation.
    def publish(opts = {})
      current_publish_entries = {}
      Hyacinth::Config.lock_adapter.with_lock(self.uid) do |lock_object|
        current_publish_entries = publish_entries.dup
        before_publish_copy = self.deep_copy
        # use one DateTime to avoid multiple clock checks
        opts = opts.merge(current_datetime: DateTime.current)
        # For efficiency, use one query to get all publish targets that
        # we'll need in one query.
        potential_targets = PotentialPublishTargets.new(self)
        # Determine highest doi_priority publish target among the set that
        # this object will be published to. This will be used as the doi target.
        highest_priority_publish_entry_string_key = potential_targets.highest_priority_publish_entry(self.publish_entries)

        # Handle publish operations
        self.pending_publish_to.dup.each do |publish_target_string_key|
          opts[:update_doi_url] = (highest_priority_publish_entry_string_key == publish_target_string_key)
          publish_to(potential_targets[publish_target_string_key], current_publish_entries, opts)
          lock_object.extend_lock # extend lock in case publish is slow
        end

        # Handle unpublish operations
        self.pending_unpublish_from.dup.each do |publish_target_string_key|
          opts[:update_doi_url] = (highest_priority_publish_entry_string_key == publish_target_string_key)
          unpublish_from(potential_targets[publish_target_string_key], current_publish_entries, opts)
          lock_object.extend_lock # extend lock in case unpublish is slow
        end
        # Reset pending entries after successful un/publish.
        self.assign_pending_publish_entries({})
        self.publish_entries = current_publish_entries.freeze unless current_publish_entries.blank?
        self.write_to_metadata_storage
      rescue StandardError => e
        # We can't easily revert publish operations because:
        # 1. Often, we still want to publish to one publish
        #    target even if a second one fails to publish.
        # 2. If one publish target was successfully unpublished,
        #    but another publish target failed to publish or
        #    unpublish, we don't necessarily want to revert
        #    an unpublish by publishing the latest version
        #    of the record data.
        #
        # ...So what we do in this rescue block is just make sure
        # to document whatever was successful, by updating the
        # publish target entries, and then re-save the DigitalObject.
        # We'll still clear out the pending_publish_to and
        # pending_unpublish_from fields regardless of what succeeded
        # though, since we require the user to be explicit about what
        # kind of publish or unpublish attempts they want to retry.

        # In the case of an exception, the only thing we'll potentially revert is the
        # first_published_at time (in case this is the first time we're publishing).
        self.first_published_at = before_publish_copy.first_published_at
        self.publish_entries = current_publish_entries.freeze unless current_publish_entries.blank?
        raise e # pass along the exception
      end

      self.errors.blank?
    end

    # Unpublishes this object from all of its current publish targets
    # and clears out publish_entries.
    def unpublish_from_all
      return if publish_entries.blank?
      self.pending_unpublish_from = publish_entries.keys
      publish
    end

    private

      def publish_to(publish_target, current_publish_entries, opts = {})
        publication_adapter = Hyacinth::Config.publication_adapter
        publish_result, messages = publication_adapter.publish(publish_target, self, opts[:update_doi_url])
        if publish_result
          # Remove pending_publish_to and add publish entry
          pending_publish_to.delete(publish_target.string_key)
          publish_entry = {
            published_at: (opts[:current_datetime] || DateTime.current),
            published_by: opts[:user]
          }
          # if result was true, messages array should be the published url
          publish_entry[:cited_at] = messages.first if opts[:update_doi_url]
          current_publish_entries[publish_target.string_key] = Hyacinth::PublishEntry.new(publish_entry)
        else
          self.errors.add(:publish_to, "Failed to publish to #{publish_target.string_key}. See error log for details.")
          Rails.logger.error("Failed to publish #{self.uid} to #{publish_target.string_key} due to the following errors: #{messages.join(', ')}")
        end
      end

      def unpublish_from(publish_target, current_publish_entries, opts = {})
        publication_adapter = Hyacinth::Config.publication_adapter
        unpublish_result, errors = publication_adapter.unpublish(publish_target, self, opts[:update_doi_url])
        if unpublish_result
          # Remove pending_unpublish_from and publish entry
          pending_unpublish_from.delete(publish_target.string_key)
          current_publish_entries.delete(publish_target.string_key)
        else
          self.errors.add(:unpublish_from, "Failed to unpublish from #{publish_target.string_key}. See error log for details.")
          Rails.logger.error("Failed to unpublish #{self.uid} from #{publish_target.string_key} due to the following errors: #{errors.join(', ')}")
        end
      end

      # Given a publish entries Hash, returns the string key of the publish target with the highest
      # doi priority, ignoring any publish targets that have an is_valid_doi_location value of false.
      # @param pub_entries [Hash] A Hash of publish target string keys to publish entries.
      # @param publish_target_string_keys_to_publish_targets [Hash] A Hash of publish target string keys to PublishTarget instances
      # @return [String] The string_key of the highest priority publish entry,
      # or nil if none of the publish targets meet the requirements necessary to
      # be considered for prioritization.
      def select_highest_priority_publish_entry(pub_entries, publish_target_string_keys_to_publish_targets)
        pub_entries.keys.select do |publish_target_string_key|
          publish_target_string_keys_to_publish_targets[publish_target_string_key].valid_doi_location?
        end.max_by do |publish_target_string_key|
          publish_target_string_keys_to_publish_targets[publish_target_string_key].doi_priority
        end
      end

      class PotentialPublishTargets
        delegate :[], to: :@targets
        def initialize(digital_object)
          @targets = PublishTarget.where(
            string_key: (digital_object.pending_publish_to + digital_object.pending_unpublish_from + digital_object.publish_entries.keys).uniq
          ).map do |publish_target|
            [publish_target.string_key, publish_target]
          end.to_h
        end

        # Given a publish entries Hash, returns the string key of the publish target with the highest
        # doi priority, ignoring any publish targets that have an is_valid_doi_location value of false.
        # @param pub_entries [Hash] A Hash of publish target string keys to publish entries.
        # @return [String] The string_key of the highest priority publish entry,
        # or nil if none of the publish targets meet the requirements necessary to
        # be considered for prioritization.
        def highest_priority_publish_entry(pub_entries)
          pub_entries.keys.select do |publish_target_string_key|
            self[publish_target_string_key].valid_doi_location?
          end.max_by do |publish_target_string_key|
            self[publish_target_string_key].doi_priority
          end
        end
      end
  end
end
