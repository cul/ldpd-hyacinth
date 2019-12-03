# frozen_string_literal: true

module Hyacinth
  module Adapters
    module AdapterManagerBehavior
      extend ActiveSupport::Concern

      module ClassMethods
        def registered_adapters
          @registered_adapters ||= {}
        end

        def register(adapter_type, adapter_class)
          registered_adapters[adapter_type.to_sym] = adapter_class
        end

        def find(adapter_type)
          registered_adapters[adapter_type.to_sym]
        end

        def create(adapter_config)
          adapter_type = adapter_config[:type]
          adapter_class = find(adapter_type.to_sym)
          raise Hyacinth::Exceptions::AdapterNotFoundError, "No adapter found with type: #{adapter_type.inspect}" if adapter_class.nil?
          adapter_class.new(adapter_config)
        end
      end
    end
  end
end
