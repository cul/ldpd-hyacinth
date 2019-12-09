# frozen_string_literal: true

module Hyacinth
  module Adapters
    def self.create_from_config(config)
      raise Hyacinth::Exceptions::AdapterNotFoundError, 'Missing type' if config[:type].blank?

      begin
        klass = config[:type].constantize
      rescue NameError
        raise Hyacinth::Exceptions::AdapterNotFoundError, "Could not resolve constant: #{config[:type]}"
      end

      klass.new(config)
    end
  end
end
