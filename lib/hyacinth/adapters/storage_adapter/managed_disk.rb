# frozen_string_literal: true

module Hyacinth
  module Adapters
    module StorageAdapter
      class ManagedDisk < Abstract
        include Disk::ReadableWritableDiskBehavior

        def initialize(adapter_config = {})
          raise 'Missing config option: adapters' if adapter_config[:default_path].blank?
          @default_path = adapter_config[:default_path]
          super(adapter_config)
        end
      end
    end
  end
end
