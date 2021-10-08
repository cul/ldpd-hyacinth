# frozen_string_literal: true

class DigitalObject::ProjectsValidator < ActiveModel::Validator
  def validate(digital_object)
    primary_string_key = digital_object.primary_project&.string_key
    return unless digital_object.other_projects&.detect { |proj| proj.string_key == primary_string_key }
    digital_object.errors.add(:other_projects, "Other projects cannot also be primary: #{primary_string_key}")
  end
end
