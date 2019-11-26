# frozen_string_literal: true

module Hyacinth
  module DigitalObject
    module State
      ACTIVE = 'active'
      WITHDRAWN = 'withdrawn'

      VALID_STATES = [ACTIVE, WITHDRAWN].freeze
    end
  end
end
