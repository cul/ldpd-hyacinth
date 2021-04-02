# frozen_string_literal: true

class ResourceRequests::AbstractJob < ApplicationJob
  def self.perform_later_if_eligible(digital_object)
    perform_later(digital_object.uid) if eligible_object?(digital_object)
  end

  # This method should be overridden by subclasses.
  def self.eligible_object?(_digital_object)
    raise NotImplementedError
  end
end
