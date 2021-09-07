# frozen_string_literal: true

module Inputs
  class ChildStructureInput < Types::BaseInputObject
    description 'Structural information attributes for a single ordered child object within a set of ordered child objects'

    argument :uid, String, required: true
    argument :sort_order, Int, required: true
  end
end
