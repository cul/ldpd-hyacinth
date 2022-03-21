# frozen_string_literal: true

module Types
  class TitleType < Types::BaseObject
    description 'A title'

    class TitleValueType < Types::BaseObject
      field :sort_portion, String, null: false
      field :non_sort_portion, String, null: true
    end

    class ValueLangType < Types::BaseObject
      field :tag, String, null: false
    end

    field :value, Types::TitleType::TitleValueType, null: true
    field :value_lang, Types::TitleType::ValueLangType, null: true
    field :subtitle, String, null: true
  end
end
