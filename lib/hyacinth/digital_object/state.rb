# frozen_string_literal: true

module Hyacinth
  module DigitalObject
    module State
      ACTIVE = 'active'
      DELETED = 'deleted'

      VALID_STATES = [ACTIVE, DELETED].freeze
    end
  end
end
