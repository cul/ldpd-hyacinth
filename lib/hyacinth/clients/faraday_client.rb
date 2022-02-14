# frozen_string_literal: true

module Hyacinth
  module Clients
    class FaradayClient
      def initialize(default_job_options:, **other_opts)
        @default_job_options = default_job_options
        init_connection(other_opts)
      end

      def init_connection(url:, api_key:, request_timeout: 120, **_other_opts)
        @conn = Faraday.new(
          url: url,
          headers: {
            'Content-Type' => 'application/json',
            'Accept' => 'application/json'
          },
          # A longer request timeout can be useful in a development environment when long-running
          # background jobs are running inline.
          request: {
            timeout: request_timeout
          }
        ) do |c|
          c.request :authorization, 'Bearer', token: api_key
        end
        @conn
      end

      def with_connection_and_opts(request_type = 'default', options = {}, &block)
        # Merge default options and provided options (with provided options overwriting default ones)
        options = @default_job_options.fetch(request_type.to_sym, {}).with_indifferent_access.merge(options)

        block.yield(@conn, options)
      end
    end
  end
end
