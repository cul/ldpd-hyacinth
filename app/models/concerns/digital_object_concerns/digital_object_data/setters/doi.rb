# frozen_string_literal: true

module DigitalObjectConcerns
  module DigitalObjectData::Setters
    module Doi
      extend ActiveSupport::Concern

      def set_doi(digital_object_data)
        return unless digital_object_data.key?('doi').present?
        doi_value = digital_object_data['doi']
        return if doi_value == self.doi # no-op if same as current doi
        raise Hyacinth::Exceptions::AlreadySet, "Cannot set doi because doi has already been set." if self.doi.present?
        self.doi = digital_object_data['doi']
      end

      def set_mint_doi(digital_object_data)
        return unless digital_object_data.key?('mint_doi')
        return if self.doi.present? # no-op if doi has already been minted
        @mint_doi = digital_object_data['mint_doi'].to_s.downcase == 'true'
      end
    end
  end
end
