# frozen_string_literal: true

class DigitalObject::ResourceImportValidator < ActiveModel::Validator
  def validate(digital_object)
    validate_resource_import_keys(digital_object)
    validate_resource_imports(digital_object)
  end

  private

    def validate_resource_import_keys(digital_object)
      invalid_import_keys = digital_object.resource_imports.keys.map(&:to_sym) - digital_object.resource_import_attributes.keys.map(&:to_sym)
      return if invalid_import_keys.blank?
      digital_object.errors.add(:resource_imports, "Invalid resource import keys: #{invalid_import_keys.to_a.join(', ')}") if invalid_import_keys.present?
    end

    def validate_resource_imports(digital_object)
      digital_object.resource_imports.each do |resource_import_name, resource_import|
        next if resource_import.nil?

        # Ensure that resource import has valid properties
        digital_object.errors.add("resource_imports.#{resource_import_name}", "Invalid resource import: #{resource_import_name}") unless resource_import.valid?

        # Ensure that the resource import location readable. Even if this is expensive in some
        # cases, it's better to catch an unreadable resource early before importing an incomplete
        # set of imports and discovering one wasn't readable before a save has completed.
        digital_object.errors.add("resource_imports.#{resource_import_name}", "Unreadable file for resource import: #{resource_import_name}") unless resource_import.location_is_readable?
      end
    end
end
