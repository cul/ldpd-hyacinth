# frozen_string_literal: true

class DigitalObject::ProjectsValidator < ActiveModel::Validator
  def validate(digital_object)
    digital_object.errors[:projects] << "Only primary projects can be assigned to primary_project" if digital_object.primary_project && !digital_object.primary_project.is_primary
    return unless digital_object.other_projects.detect(&:is_primary)
    digital_object.errors[:projects] << "An item can only have one primary project, and it must be assigned to primary_project"
  end
end
