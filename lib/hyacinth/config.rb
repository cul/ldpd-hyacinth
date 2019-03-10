module Hyacinth
  module Config
    attr_reader :digital_object_types, :metadata_storage, :resource_storage, :search_adapter, :lock_adapter

    def initialize(digital_object_types, metadata_storage, resource_storage, search_adapter, lock_adapter)
    end
  end
end
