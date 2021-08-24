# frozen_string_literal: true

module Types
  class TitleType < Types::BaseObject
    description 'A title'

    field :sort_portion, String, null: true
    field :non_sort_portion, String, null: true
    field :subtitle, String, null: true
    field :lang, String, null: true
  end
end
