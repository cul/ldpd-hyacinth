module FacetsHelper
  def url_for_add_facet(facet_field, facet_value)
    facet_field = facet_field.to_s

    # Copy params because we don't want to modify the existing params hash
    params_copy = params.dup
    params_copy[:f] = (params_copy[:f] || {}).dup
    params_copy[:f][facet_field] = (params_copy[:f][facet_field] || []).dup

    params_copy[:f][facet_field].push(facet_value) unless params_copy[:f][facet_field].include?(facet_value)

    params_copy.delete(:page) # Adding a facet changes the search results, so the current page is no longer relevant

    url_for(params_copy)
  end

  def url_for_remove_facet(facet_field, facet_value)
    facet_field = facet_field.to_s

    # Copy params because we don't want to modify the existing params hash
    params_copy = params.dup
    params_copy[:f] = (params_copy[:f] || {}).dup
    params_copy[:f][facet_field] = (params_copy[:f][facet_field] || []).dup

    params_copy[:f][facet_field].delete(facet_value) if params_copy[:f][facet_field].include?(facet_value)

    params_copy.delete(:page) # Removing a facet changes the search results, so the current page is no longer relevant

    url_for(params_copy)
  end

  def render_facet_link(field, facet_object)
    if facet_is_active?(field, facet_object.value)
      return ((facet_object.value.blank? ? '[Blank]' : facet_object.value) + ' [' + facet_object.count.to_s + ']').html_safe + ' ' + link_to('[ x ]', url_for_remove_facet(field, facet_object.value))
    else
      return link_to((facet_object.value.blank? ? '[Blank]' : facet_object.value), url_for_add_facet(field, facet_object.value)) + (' [' + facet_object.count.to_s + ']').html_safe
    end
  end

  def facet_is_active?(field, value)
    (params[:f] && params[:f][field] && params[:f][field].include?(value))
  end

  def render_hidden_form_fields_for_params
    html_to_return = ''

    params_to_exclude = [:controller, :action, :f, :search_type, :q, :utf8] # These are handled in other ways.  Not in the iterator below.
    # Handle top level params
    params.each do |param_key, param_value|
      next if params_to_exclude.include?(param_key.to_sym)

      if param_value.is_a?(Array)
        param_value.each do |single_val_from_array|
          html_to_return += hidden_field_tag(param_key + '[]', single_val_from_array, id: nil)
        end
      else
        html_to_return += hidden_field_tag(param_key, param_value, id: nil)
      end
    end

    # Handle facets
    if params[:f]
      params[:f].each do |facet_field, facet_values|
        facet_values.each do |facet_value|
          html_to_return += hidden_field_tag('f[' + facet_field + '][]', facet_value, id: nil)
        end
      end
    end

    html_to_return.html_safe
  end

  def render_facet_pills_for_active_facets
    html_to_return = ''
    if params[:f]
      all_item_facet_fields = DigitalObject.get_indexing_rules['facet']

      # return all_item_facet_fields.inspect

      params[:f].each do |facet_field, facet_values|
        if all_item_facet_fields[facet_field][:display_label].present?
          # First check for specifically-defined facet field label in case we want to override the label
          standalone_field_label = all_item_facet_fields[facet_field][:display_label]
        else
          raise 'Missing display label for facet field: ' + facet_field
        end

        facet_values.each do |facet_value|
          html_to_return += link_to("<span class=\"glyphicon glyphicon-remove\"></span> #{standalone_field_label}: ".html_safe + facet_value, url_for_remove_facet(facet_field, facet_value), class: 'btn btn-default btn-xs facet_pill') + ' '.html_safe
        end
      end
    end
    html_to_return.html_safe
  end
end
