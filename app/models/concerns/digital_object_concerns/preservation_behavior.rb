module DigitalObjectConcerns
  module PreservationBehavior
    extend ActiveSupport::Concern

    # Persists this object to preservation storage.
    # Note: This method calls save on the digital object because successful
    # preserving modifies the object's preservation timestamps.
    # @param publishing_user [User] user who is initiating this publish operation.
    def preserve
      # Make sure that preservation target URIs have already been minted for all preservation targets.
      set_missing_preservation_target_uris

      # When preserving, we mint a reserved DOI if we don't have one already.
      # TODO: Make the line below functional
      mint_reserved_doi_if_blank

      success, errors = Hyacinth.config.preservation_persistence.persist(self)

      if success
        set_preservation_timestamps
        self.save # Save digital object because we just updated various properties as part of the preservation operation
      else
        self.errors.add(:preservation, "The following errors occurred during preservation: #{errors.join("\n")}")
      end
    end

    # Generates and sets preservation target URIs for any preservation targets not yet accounted for.
    def set_missing_preservation_target_uris
      Hyacinth.config.preservation_persistence.preservation_adapters.each do |adapter|
        uri = digital_object.preservation_target_uris.find { |preservation_target_uri| adapter.handles?(preservation_target_uri) }
        if uri.nil?
          self.preservation_target_uris << adapter.generate_new_location_uri
        end
      end
    end

    # Updated preservation timestamps (first_persisted_to_preservation_at and persisted_to_preservation_at)
    def set_preservation_timestamps
      current_datetime = DateTime.now
      # If this is the first time we've persisted this item to preservation, make a note of the date/time.
      self.first_persisted_to_preservation_at = current_datetime unless self.first_persisted_to_preservation_at.present?
      # Make a note of the latest preservation time.
      self.persisted_to_preservation_at = current_datetime
    end

    def mint_reserved_doi_if_blank
      # TODO: Make line below functional
      # self.doi = DoiManager.mint_reserved_doi if self.doi.blank?
    end
  end
end
