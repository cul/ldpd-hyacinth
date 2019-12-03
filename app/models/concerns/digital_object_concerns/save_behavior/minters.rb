# frozen_string_literal: true

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

      def mint_reserved_doi_if_doi_blank
        return if self.doi.present?
        self.instance_variable_set :@doi, Hyacinth.config.external_identifier_adapter.mint
      end

      def mint_uid_and_metadata_location_uri_if_new_record
        return unless self.new_record?
        self.uid = self.mint_uid # generate a new uid for this object
        self.digital_object_record.uid = self.uid # assign that uid to this object's digital_object_record
        self.digital_object_record.metadata_location_uri = Hyacinth.config.metadata_storage.generate_new_location_uri(self.digital_object_record.uid)
      end
    end
  end
end
