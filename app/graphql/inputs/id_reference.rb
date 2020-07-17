# frozen_string_literal: true

module Inputs
  class IdReference < Types::BaseInputObject
    description 'id property input type'

    argument :id, ID, required: true
  end
end
