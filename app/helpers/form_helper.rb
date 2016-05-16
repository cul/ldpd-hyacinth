module FormHelper
  def setup_dynamic_field(dynamic_field)
    # Generate blank dynamic_subfield
    dynamic_field.dynamic_subfields.build

    dynamic_field
  end

  def setup_digital_object_type(digital_object_type)
    # Set up system_expected_dynamic_subfields

    current_set_of_system_expected_dynamic_subfields = digital_object_type.system_expected_dynamic_subfields.map(&:dynamic_subfield)
    DynamicSubfield.all.each do |dynamic_subfield|
      # Only build elements if they're not already included in this digital_object_type's set of system_expected_dynamic_subfields
      next if current_set_of_system_expected_dynamic_subfields.include?(dynamic_subfield)

      digital_object_type.system_expected_dynamic_subfields.build(dynamic_subfield: dynamic_subfield)
    end
  end

  def setup_project_for_add_fields_and_subfields_view(project, digital_object_type)
    # Set up enabled_dynamic_subfields

    current_set_of_enabled_dynamic_subfields = project.enabled_dynamic_subfields.where(digital_object_type: digital_object_type).map(&:dynamic_subfield)
    DynamicSubfield.all.each do |dynamic_subfield|
      next if current_set_of_enabled_dynamic_subfields.include?(dynamic_subfield)
      # Only build elements if they're not already included in this project's set of enabled_dynamic_subfields
      project.enabled_dynamic_subfields.build(dynamic_subfield: dynamic_subfield, digital_object_type: digital_object_type)
    end
  end

  def setup_digital_object_for_form!(digital_object, build_missing_dynamic_attributes = true)
    ### Build any missing dynamic attributes (and dynamic_subfields) for this object, based on its project and data_element_type ###

    enabled_dynamic_subfields = digital_object.project.enabled_dynamic_subfields.map(&:dynamic_subfield)

    # Build missing dynamic_attribute_properties for currently represented dynamic_attributes, but only for enabled_dynamic_subfields
    digital_object.dynamic_attributes.each do |dynamic_attribute|
      possible_dynamic_subfields = dynamic_attribute.dynamic_field.dynamic_subfields

      expected_dynamic_subfields = possible_dynamic_subfields & enabled_dynamic_subfields # Only expect dynamic_subfields that are possible for this dynamic_field AND on the list of enabled_dynamic_subfields

      currently_reflected_dynamic_subfields = dynamic_attribute.dynamic_attribute_properties.map(&:dynamic_subfield)
      missing_dynamic_subfields = expected_dynamic_subfields - currently_reflected_dynamic_subfields

      missing_dynamic_subfields.each do |dynamic_subfield|
        dynamic_attribute.dynamic_attribute_properties.build(dynamic_subfield: dynamic_subfield)
      end
    end

    return unless build_missing_dynamic_attributes

    currently_represented_dynamic_fields = digital_object.dynamic_attributes.map(&:dynamic_field)
    all_enabed_dynamic_subfields_for_digital_object_type = digital_object.project.enabled_dynamic_subfields.includes(dynamic_subfield: [:dynamic_field]).where(
      digital_object_type: digital_object.digital_object_type
    )
    all_enabled_dynamic_fields = all_enabed_dynamic_subfields_for_digital_object_type.map { |enabled_dynamic_subfield| enabled_dynamic_subfield.dynamic_subfield.dynamic_field }.uniq

    missing_dynamic_fields = all_enabled_dynamic_fields - currently_represented_dynamic_fields

    # Build dynamic_attributes (and associated dynamic_attribute_properties) for dynamic_fields that are not currently represented
    missing_dynamic_fields.each do |dynamic_field|
      new_dynamic_attribute = digital_object.dynamic_attributes.build(dynamic_field: dynamic_field)
      dynamic_field.dynamic_subfields.each do |dynamic_subfield|
        # But only build the possible dynamic subfield if it's in enabled_dynamic_subfields
        next unless enabled_dynamic_subfields.include?(dynamic_subfield)
        new_dynamic_attribute.dynamic_attribute_properties.build(dynamic_subfield: dynamic_subfield)
      end
    end
  end
end
