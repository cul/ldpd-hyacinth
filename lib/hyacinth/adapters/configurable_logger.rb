# frozen_string_literal: true

module Hyacinth
  module Adapters
    module ConfigurableLogger
      extend ActiveSupport::Concern
      included do
        attr_accessor :logger
      end

      def configure_logger(config)
        @logger = configured_logger(**config)
      end

      # @param logger [Hash] config for adapter logging
      def configured_logger(logger: {}, **_rest)
        if logger.present?
          logdev = logger[:dev] || Rails.logger.instance_variable_get(:@logdev)
          logdev = Rails.root.join('log', logdev) if logdev.is_a? String
          level = logger[:log_level]&.to_sym || Rails.logger.instance_variable_get(:@level)
          ActiveSupport::Logger.new(logdev, level: level)
        else
          Rails.logger
        end
      end
    end
  end
end
