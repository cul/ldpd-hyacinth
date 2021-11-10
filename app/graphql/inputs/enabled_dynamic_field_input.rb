# frozen_string_literal: true

module Inputs
  class EnabledDynamicFieldInput < Types::BaseInputObject
    description 'Attributes for an enabled dynamic field in a project for a digital obect type'

    argument :dynamic_field, Inputs::IdReference, required: true
    argument :field_sets, [Inputs::IdReference], required: true
    argument :required, Boolean, required: true
    argument :locked, Boolean, required: false # TODO: HYACINTH-923 - Get rid of this field if it's not useful
    argument :hidden, Boolean, required: false # TODO: HYACINTH-923 - Get rid of this field if it's not useful
    argument :owner_only, Boolean, required: false # TODO: HYACINTH-923 - Get rid of this field if it's not useful
    argument :shareable, Boolean, required: true

    argument :default_value, String, required: false
  end
end
