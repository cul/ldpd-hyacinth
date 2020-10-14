# frozen_string_literal: true

class Enums::SearchTypeEnum < Types::BaseEnum
  ::Hyacinth::Config.digital_object_search_adapter.search_types.each do |type|
    value type.upcase, type, value: type
  end
end
