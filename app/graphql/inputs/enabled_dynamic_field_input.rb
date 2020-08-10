# frozen_string_literal: true

module Inputs
  class EnabledDynamicFieldInput < Types::BaseInputObject
    description 'Attributes for an enabled dynamic field in a project for a digital obect type'

    argument :dynamic_field, Inputs::IdReference, required: true
    argument :field_sets, [Inputs::IdReference], required: true
    argument :required, Boolean, required: true
    argument :locked, Boolean, required: true
    argument :hidden, Boolean, required: true
    argument :owner_only, Boolean, required: true
    argument :shareable, Boolean, required: true

    argument :default_value, String, required: false
  end
end
