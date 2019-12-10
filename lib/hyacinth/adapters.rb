# frozen_string_literal: true

module Hyacinth
  module Adapters
    def self.create_from_config(adapter_namespace, config)
      raise Hyacinth::Exceptions::AdapterNotFoundError, 'Missing type' if config[:type].blank?
      class_string = "#{adapter_namespace}::#{config[:type]}"

      begin
        klass = class_string.constantize
      rescue NameError
        raise Hyacinth::Exceptions::AdapterNotFoundError, "Could not resolve constant: #{class_string}"
      end

      klass.new(config)
    end
  end
end
