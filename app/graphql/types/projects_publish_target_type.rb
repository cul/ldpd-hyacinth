# frozen_string_literal: true

module Types
  class ProjectsPublishTargetType < Types::PublishTargetType
    description 'A publish target annotated with an enabled flag for the queried project'

    field :enabled, Boolean, null: false
  end
end
