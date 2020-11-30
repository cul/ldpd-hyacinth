# frozen_string_literal: true

class Enums::DigitalObjectStateEnum < Types::BaseEnum
  ::Hyacinth::DigitalObject::State::VALID_STATES.each do |state|
    value state.upcase.tr(' ', '_'), state.camelize, value: state
  end
end
