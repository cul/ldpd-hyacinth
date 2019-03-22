module DigitalObjectConcerns
  module SaveBehavior
    # Methods that check whether certain actions should be taken or whether
    # certain things changed that would trigger actions.
    module ActionChecks
      extend ActiveSupport::Concern

      def should_preserve?
        # Always preserve if @preserve has been set to true.  Also preserve whenever
        # we're doing a publish_to operation.  If @preserve is false and we're only
        # unpublishing, there's no need to preserve.
        @preserve || self.publish_to.present?
      end

      def should_publish?
        self.publish_to.present? || self.unpublish_from.present?
      end

      def parents_changed?
        @parent_uids_to_add.present? || @parent_uids_to_remove.present?
      end
    end
  end
end
