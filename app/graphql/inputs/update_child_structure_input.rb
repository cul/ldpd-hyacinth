# frozen_string_literal: true

module Inputs
  class UpdateChildStructureInput < Types::BaseInputObject
    description 'Attributes for reordering child objects of a digital obect'

    argument :uid, String, required: true
    argument :sort_order, Int, required: true
  end
end
