# frozen_string_literal: true

class ChangeDynamicFieldPathsJob < ApplicationJob
  # TODO: HYACINTH-649 implement path changes triggered by a string_key change
  #       in a DynamicFieldGroup or DynamicField
  # @param [Hash] path_changes: a map of old to new path values
  def self.perform(path_changes); end
end
