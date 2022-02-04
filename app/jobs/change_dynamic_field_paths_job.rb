# frozen_string_literal: true

class ChangeDynamicFieldPathsJob < ApplicationJob
  queue_as :modify_dynamic_fields
  # TODO: HYACINTH-649 implement path changes triggered by a string_key change
  #       in a DynamicFieldGroup or DynamicField
  # @param [Hash] path_changes: a map of old to new path values
  def perform(path_changes); end
end
