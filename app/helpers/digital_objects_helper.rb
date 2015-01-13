module DigitalObjectsHelper

  def get_digital_object_thumbnail_img_tag(digital_object, url_to_link_to=nil, show_title=false)

    object_to_render = nil

    if digital_object.digital_object_type == DigitalObjectType.get_type_asset
      object_to_render = digital_object
    elsif digital_object.digital_object_type == DigitalObjectType.get_type_item
      # Get first child asset
      results = digital_object.child_digital_objects.limit(1)
      if results.present?
        object_to_render = results.first
      end
    end

    if object_to_render.present?
      html_to_return = ''
      html_to_return += '<div class="thumb-image">'
      html_to_return += '<a class="thumb-link" href="' + url_to_link_to + '">' if url_to_link_to.present?
      html_to_return += '<span class="image-container">'
      html_to_return +=  image_tag(get_digital_object_path(:pid => object_to_render.pid, :size => 'thumb'), :alt => 'Asset Image')
      html_to_return += '</span>'
      html_to_return += '</a>' if url_to_link_to.present?
      html_to_return += '<a href="#" class="zoom-link btn btn-default btn-sm" onclick="Hyacinth.DigitalObjects.showAssetInDialog(\'' + object_to_render.pid + '\'); return false;"><span class="glyphicon glyphicon-zoom-in"></span></a>'
      html_to_return += '<div class="ellipsis aligncenter"><small>' + digital_object.get_full_title + '</small></div>' if show_title
      html_to_return += '</div>'
      return html_to_return.html_safe
    else
      return nil
    end

  end

  # Returns a hash of Sort-Order-Sorted DynamicFieldGroups TO Grouped And Sort-Order-Sorted DynamicAttributes
  def get_sorted_dynamic_field_groups_to_sorted_dynamic_fields_to_non_sorted_dynamic_attributes(digital_object)

    sorted_dynamic_field_groups_to_sorted_dynamic_fields_to_non_sorted_dynamic_attributes = {}
    digital_object.dynamic_attributes.sort_by{|dynamic_attribute| [dynamic_attribute.dynamic_field.dynamic_field_group.sort_order, dynamic_attribute.dynamic_field.sort_order]}.each {|dynamic_attribute|

      # Structure:
      # {
      #   'DynamicFieldGroup' => {
      #     'DynamicField' => [DynamicAttribute, DynamicAttribute]
      #     'DynamicField' => [DynamicAttribute, DynamicAttribute]
      #   }
      #   'DynamicFieldGroup' => {
      #     'DynamicField' => [DynamicAttribute, DynamicAttribute]
      #     'DynamicField' => [DynamicAttribute, DynamicAttribute]
      #   }
      # }

      # Top level: DynamicFieldGroup display label
      if sorted_dynamic_field_groups_to_sorted_dynamic_fields_to_non_sorted_dynamic_attributes[dynamic_attribute.dynamic_field.dynamic_field_group].nil?
        sorted_dynamic_field_groups_to_sorted_dynamic_fields_to_non_sorted_dynamic_attributes[dynamic_attribute.dynamic_field.dynamic_field_group] = {}
      end

      # Second level: DynamicField display label
      if sorted_dynamic_field_groups_to_sorted_dynamic_fields_to_non_sorted_dynamic_attributes[dynamic_attribute.dynamic_field.dynamic_field_group][dynamic_attribute.dynamic_field].nil?
        sorted_dynamic_field_groups_to_sorted_dynamic_fields_to_non_sorted_dynamic_attributes[dynamic_attribute.dynamic_field.dynamic_field_group][dynamic_attribute.dynamic_field] = []
      end

      # Third level: DynamicAttribute
      sorted_dynamic_field_groups_to_sorted_dynamic_fields_to_non_sorted_dynamic_attributes[dynamic_attribute.dynamic_field.dynamic_field_group][dynamic_attribute.dynamic_field] << dynamic_attribute

    }

    return sorted_dynamic_field_groups_to_sorted_dynamic_fields_to_non_sorted_dynamic_attributes

  end

  def hidden_search_param_persistence_tags
    return (params[:search_params_string].blank? ? '' : hidden_field_tag(:search_params_string, params[:search_params_string])) +
      (params[:search_result_counter].blank? ? '' : hidden_field_tag(:search_result_counter, params[:search_result_counter]))
  end

end
