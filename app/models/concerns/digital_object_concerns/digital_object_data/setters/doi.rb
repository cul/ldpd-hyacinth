module DigitalObjectConcerns
  module DigitalObjectData::Setters
    module Doi
      extend ActiveSupport::Concern

      def set_doi(digital_object_data)
        return unless digital_object_data.key?('doi')
        self.doi = digital_object_data['doi']
      end

      def set_mint_doi(digital_object_data)
        return unless digital_object_data.key?('doi')
        @mint_doi = digital_object_data['mint_doi'].to_s.downcase == 'true'
      end
    end
  end
end
