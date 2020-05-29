# frozen_string_literal: true

module DigitalObject
  class Item < DigitalObject::Base
    def initialize
      super
    end

    def can_have_rights?
      true
    end
  end
end
