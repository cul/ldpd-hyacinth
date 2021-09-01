# frozen_string_literal: true

module Inputs
  class DigitalObject::TitleInput < Types::BaseInputObject
    description 'Digital Object Title Parameters'
    class ValueInput < Types::BaseInputObject
      argument :sort_portion, String, required: true
      argument :non_sort_portion, String, required: false
    end
    class ValueLangInput < Types::BaseInputObject
      argument :tag, String, required: true
    end

    argument :value, Inputs::DigitalObject::TitleInput::ValueInput, required: false
    argument :value_lang, Inputs::DigitalObject::TitleInput::ValueLangInput, required: false
    argument :subtitle, String, required: false
  end
end
