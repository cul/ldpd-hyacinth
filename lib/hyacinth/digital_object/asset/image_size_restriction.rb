# frozen_string_literal: true

module Hyacinth
  module DigitalObject
    module Asset
      module ImageSizeRestriction
        NONE = 'none'
        DOWNSCALE_UNLESS_AUTHORIZED = 'downscale_unless_authorized'
        DENY_UNLESS_AUTHORIZED = 'deny_unless_authorized'

        VALID_IMAGE_SIZE_RESTRICTIONS = [NONE, DOWNSCALE_UNLESS_AUTHORIZED, DENY_UNLESS_AUTHORIZED].freeze
      end
    end
  end
end
