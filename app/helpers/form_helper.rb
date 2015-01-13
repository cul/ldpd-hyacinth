module FormHelper

  def setup_dynamic_field(dynamic_field)

    # Generate blank dynamic_subfield
    dynamic_field.dynamic_subfields.build

    return dynamic_field

  end

  def setup_digital_object_type(digital_object_type)
    # Set up system_expected_dynamic_subfields

    current_set_of_system_expected_dynamic_subfields = digital_object_type.system_expected_dynamic_subfields.map{|system_expected_dynamic_subfield| system_expected_dynamic_subfield.dynamic_subfield}
    DynamicSubfield.all.each {|dynamic_subfield|
      # Only build elements if they're not already included in this digital_object_type's set of system_expected_dynamic_subfields
      if ! current_set_of_system_expected_dynamic_subfields.include?(dynamic_subfield)
        digital_object_type.system_expected_dynamic_subfields.build(:dynamic_subfield => dynamic_subfield)
      end
    }
  end

  def setup_project_for_add_fields_and_subfields_view(project, digital_object_type)
    # Set up enabled_dynamic_subfields

    current_set_of_enabled_dynamic_subfields = project.enabled_dynamic_subfields.where(digital_object_type: digital_object_type).map{|enabled_dynamic_subfield| enabled_dynamic_subfield.dynamic_subfield}
    DynamicSubfield.all.each {|dynamic_subfield|
      # Only build elements if they're not already included in this project's set of enabled_dynamic_subfields
      if ! current_set_of_enabled_dynamic_subfields.include?(dynamic_subfield)
        project.enabled_dynamic_subfields.build(:dynamic_subfield => dynamic_subfield, :digital_object_type => digital_object_type)
      end
    }
  end

  def setup_digital_object_for_form!(digital_object, build_missing_dynamic_attributes=true)

    ### Build any missing dynamic attributes (and dynamic_subfields) for this object, based on its project and data_element_type ###

    enabled_dynamic_subfields = digital_object.project.enabled_dynamic_subfields.map{|enabled_dynamic_subfield|enabled_dynamic_subfield.dynamic_subfield}

    # Build missing dynamic_attribute_properties for currently represented dynamic_attributes, but only for enabled_dynamic_subfields
    digital_object.dynamic_attributes.each {|dynamic_attribute|
      possible_dynamic_subfields = dynamic_attribute.dynamic_field.dynamic_subfields

      expected_dynamic_subfields = possible_dynamic_subfields & enabled_dynamic_subfields # Only expect dynamic_subfields that are possible for this dynamic_field AND on the list of enabled_dynamic_subfields

      currently_reflected_dynamic_subfields = dynamic_attribute.dynamic_attribute_properties.map{|dynamic_attribute_property| dynamic_attribute_property.dynamic_subfield }
      missing_dynamic_subfields = expected_dynamic_subfields - currently_reflected_dynamic_subfields

      missing_dynamic_subfields.each {|dynamic_subfield|
        dynamic_attribute.dynamic_attribute_properties.build(dynamic_subfield: dynamic_subfield)
      }
    }

    if build_missing_dynamic_attributes
      currently_represented_dynamic_fields = digital_object.dynamic_attributes.map{|dynamic_attribute| dynamic_attribute.dynamic_field }
      all_enabed_dynamic_subfields_for_digital_object_type = digital_object.project.enabled_dynamic_subfields.includes(dynamic_subfield: [:dynamic_field]).where(
        digital_object_type: digital_object.digital_object_type
      )
      all_enabled_dynamic_fields = all_enabed_dynamic_subfields_for_digital_object_type.map{|enabled_dynamic_subfield|enabled_dynamic_subfield.dynamic_subfield.dynamic_field}.uniq

      missing_dynamic_fields = all_enabled_dynamic_fields - currently_represented_dynamic_fields

      # Build dynamic_attributes (and associated dynamic_attribute_properties) for dynamic_fields that are not currently represented
      missing_dynamic_fields.each {|dynamic_field|
        new_dynamic_attribute = digital_object.dynamic_attributes.build(dynamic_field: dynamic_field)
        dynamic_field.dynamic_subfields.each {|dynamic_subfield|
          # But only build the possible dynamic subfield if it's in enabled_dynamic_subfields
          new_dynamic_attribute.dynamic_attribute_properties.build(dynamic_subfield: dynamic_subfield) if enabled_dynamic_subfields.include?(dynamic_subfield)
        }
      }
    end

  end

end
