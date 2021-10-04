# frozen_string_literal: true

module DigitalObjectConcerns
  module AttributeAssignment
    module Doi
      extend ActiveSupport::Concern

      def assign_doi(digital_object_data)
        return unless digital_object_data.key?('doi').present?
        doi_value = digital_object_data['doi']
        return if doi_value == doi # no-op if same as current doi
        raise Hyacinth::Exceptions::AlreadySet, "Cannot set doi because doi has already been set." if doi.present?
        self.doi = digital_object_data['doi']
      end

      def assign_mint_doi(digital_object_data)
        return unless digital_object_data.key?('mint_doi')
        return if doi.present? # no-op if doi has already been minted
        @mint_doi = digital_object_data['mint_doi'].to_s.casecmp('true').zero?
      end

      def ensure_doi
        return if self.doi.present?
        self.doi = Hyacinth::Config.external_identifier_adapter.mint(digital_object: self)
        self.errors.add(:doi, "doi service unavailable") unless self.doi
      end

      def ensure_doi!
        ensure_doi
        self.save
      end

      private

        def ensure_doi_if_requested
          return if self.mint_doi.blank?
          ensure_doi
          self.mint_doi = false
        end
    end
  end
end
