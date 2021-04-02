# frozen_string_literal: true

module Derivativo
  class ResourceHelper
    # Returns the file path version of the location if the given resource uses a disk adapter, or
    # otherwise returns the location in its original form.
    # This method currently works the way it does because we're only handling disk-based derivative
    # src files right now, but we may one day handle access over a network protocol like https.
    def self.resource_location_for_derivativo(resource)
      resource_location = resource.location
      storage_adapter_for_location = Hyacinth::Config.resource_storage.storage_adapter_for_location(resource_location)
      raise NotImplementedError, 'Non-disk adapter locations are not currently supported by this method' unless storage_adapter_for_location.respond_to?(:location_uri_to_file_path)
      'file://' + storage_adapter_for_location.location_uri_to_file_path(resource_location)
    end
  end
end
