# frozen_string_literal: true

class Enums::DigitalObjectStateEnum < Types::BaseEnum
  DigitalObject.states.each_key do |state|
    value state.upcase.tr(' ', '_'), "Digital object state of #{state}", value: state
  end
end
