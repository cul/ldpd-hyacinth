# frozen_string_literal: true

module Hyacinth
  module Adapters
    module StorageAdapter
      class TrackedDisk < AbstractReadable
        include Disk::ReadableDiskBehavior

        def initialize(adapter_config = {})
          super(adapter_config)
        end
      end
    end
  end
end
