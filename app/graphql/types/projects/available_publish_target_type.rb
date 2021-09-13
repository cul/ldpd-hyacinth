# frozen_string_literal: true

module Types
  module Projects
    class AvailablePublishTargetType < Types::BaseObject
      description 'A publish target annotated with an enabled flag for the queried project'

      field :string_key, ID, null: false
      field :enabled, Boolean, null: false
    end
  end
end
