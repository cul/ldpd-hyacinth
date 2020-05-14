# frozen_string_literal: true

module Inputs
  class DigitalObject::OrderByInput < Types::BaseInputObject
    description 'Digital Object Sort Parameters'

    argument :field, Enums::DigitalObject::OrderFieldsEnum, required: false, default_value: 'score'
    argument :direction, Enums::OrderDirectionEnum, required: false, default_value: 'desc'
  end
end
