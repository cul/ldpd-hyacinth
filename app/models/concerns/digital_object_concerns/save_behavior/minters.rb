module DigitalObjectConcerns
  module SaveBehavior
    module Minters
      extend ActiveSupport::Concern

      def mint_uid
        # TODO: Make final decision about whether or not we want UUIDs to be our UIDs
        SecureRandom.uuid
      end

      def mint_optimistic_lock_token
        SecureRandom.uuid
      end
    end
  end
end
