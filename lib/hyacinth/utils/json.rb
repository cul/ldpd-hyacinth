# frozen_string_literal: true

module Hyacinth
  module Utils
    class Json
      def self.valid_json?(json_string)
        JSON.parse(json_string)
        true
      rescue
        false
      end
    end
  end
end
