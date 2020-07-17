# frozen_string_literal: true

module Inputs
  class Project::StringKey < Types::BaseInputObject
    description 'Project StringKey'

    argument :string_key, ID, required: true
  end
end
