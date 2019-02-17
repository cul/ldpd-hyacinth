module DigitalObjectConcerns
  module DigitalObjectDataSetters
    module PublishTargets
      extend ActiveSupport::Concern
      # TODO: Test these methods via shared_example (https://stackoverflow.com/questions/16525222/how-to-test-a-concern-in-rails)

      # included do
      #   @added_publish_targets = Set.new
      #   @removed_publish_targets = Set.new
      #
      #   attr_reader :added_publish_targets
      #   attr_reader :removed_publish_targets
      # end
      #
      def set_publish_targets(digital_object_data)
        return unless digital_object_data.key?('publish_targets')
        raise Hyacinth::Exceptions::MissingPublishFlag, 'Cannot modify publish targets unless publish flag is present.' unless digital_object_data['publish'].to_s == 'true'
        current_publish_target_string_keys = self.publish_targets.map { |publish_target| publish_target.string_key }
        new_publish_target_string_keys = digital_object_data['publish_targets'].map { |dod_publish_target| dod_publish_target['string_key'] }
        # Add new publish targets
        (new_publish_target_string_keys - current_publish_target_string_keys).each do |string_key_for_publish_target_to_add|
          add_publish_target(string_key_for_publish_target_to_add)
        end
        # Remove old publish targets
        (current_publish_target_string_keys - new_publish_target_string_keys).each do |string_key_for_publish_target_to_remove|
          remove_publish_target(
            # Re-use existing instance of PublishTarget because it's more efficient than passing a string to remove_publish_target
            self.publish_targets.find { |publish_target| publish_target.string_key == string_key_for_publish_target_to_remove }
          )
        end
      end

      # Adds the given publish target.
      # @param [PublishTarget or String] A PublishTarget to add, or the string_key of a PublishTarget to add.
      #        Passing in a PublishTarget rather than a string is slightly more efficient because it avoid a PublishTarget lookup.
      def add_publish_target(publish_target)
        raise ArgumentError, 'Cannot supply nil value for publish_target' if publish_target.nil?
        if publish_target.is_a?(String)
          publish_target = PublishTargets.find_by(string_key: string_key_for_publish_target_to_add)
          raise Hyacinth::Exceptions::NotFound, "Could not add PublishTarget with string_key \"#{publish_target}\" because it does not resolve to a known PublishTarget" if publish_target.nil?
        end
        unless self.publish_targets.include?(publish_target)
          self.publish_targets.add(publish_target)
          # added_publish_targets << publish_target
        end
      end

      # Removes the given publish target.
      # @param [PublishTarget or String] A PublishTarget to remove, or the string_key of a PublishTarget to remove.
      #        Passing in a PublishTarget rather than a string is slightly more efficient because it avoid a PublishTarget lookup.
      def remove_publish_target(publish_target)
        raise ArgumentError, 'Cannot supply nil value for publish_target' if publish_target.nil?
        if publish_target.is_a?(String)
          publish_target = PublishTargets.find_by(string_key: string_key_for_publish_target_to_add)
          raise Hyacinth::Exceptions::NotFound, "Could not remove PublishTarget with string_key \"#{publish_target}\" because it does not resolve to a known PublishTarget" if publish_target.nil?
        end
        if self.publish_targets.include?(publish_target)
          self.publish_targets.remove(publish_target)
          # removed_publish_targets << publish_target
        end
      end

    end
  end
end
