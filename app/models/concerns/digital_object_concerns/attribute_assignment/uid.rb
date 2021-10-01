# frozen_string_literal: true

module DigitalObjectConcerns
  module AttributeAssignment
    module Uid
      extend ActiveSupport::Concern

      private

        def assign_uid_if_not_exist
          return if self.uid.present?
          self.uid = mint_uid
        end

        def mint_uid
          SecureRandom.uuid
        end
    end
  end
end
