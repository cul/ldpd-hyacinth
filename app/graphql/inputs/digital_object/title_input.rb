# frozen_string_literal: true

module Inputs
  class DigitalObject::TitleInput < Types::BaseInputObject
    description 'Digital Object Title Parameters'

    argument :sort_portion, String, required: false
    argument :non_sort_portion, String, required: false
    argument :subtitle, String, required: false
    argument :lang, String, required: false
  end
end
