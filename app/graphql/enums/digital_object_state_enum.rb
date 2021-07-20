# frozen_string_literal: true

class Enums::DigitalObjectStateEnum < Types::BaseEnum
  DigitalObject.states.each_key do |state|
    value str_to_gql_enum(state), "Digital object state of #{state}", value: state
  end
end
