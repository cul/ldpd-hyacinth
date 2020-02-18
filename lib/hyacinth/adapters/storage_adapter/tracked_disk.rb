# frozen_string_literal: true

module Hyacinth
  module Adapters
    module StorageAdapter
      class TrackedDisk < Abstract
        include Disk::ReadableDiskBehavior

        def initialize(adapter_config = {})
          super(adapter_config)
        end
      end
    end
  end
end
