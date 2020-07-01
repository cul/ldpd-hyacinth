# frozen_string_literal: true

class Enums::PublishTargetTypeEnum < Types::BaseEnum
  PublishTarget::TYPES.each do |type|
    value type.upcase, type, value: type
  end
end
