module DynamicFieldsHelper

  def dynamic_field_breadcrumbs(dynamic_field_or_dynamic_field_group, active_item_is_new=false)

    breadcrumb_items = []
    current_item = dynamic_field_or_dynamic_field_group
    while(current_item.parent_dynamic_field_group.present?) do
      current_item = current_item.parent_dynamic_field_group
      breadcrumb_items << current_item
    end
    breadcrumb_items.reverse!

    html_to_return = '<ol class="breadcrumb">'

    html_to_return += '<li>' + link_to('Dynamic Fields', dynamic_fields_path)+ '</li>'
    breadcrumb_items.each do |breadcrumb_item|
      if breadcrumb_item.is_a?(DynamicField)
        html_to_return += '<li>' + link_to(CGI::escapeHTML(breadcrumb_item.display_label), edit_dynamic_field_path(breadcrumb_item)) + '</li>'
      else
        html_to_return += '<li>' + link_to(CGI::escapeHTML(breadcrumb_item.display_label), edit_dynamic_field_group_path(breadcrumb_item)) + '</li>'
      end
    end

    if active_item_is_new
      html_to_return += '<li class="active">New ' + (dynamic_field_or_dynamic_field_group.is_a?(DynamicField) ? 'Field' : 'Field Group') + '</li>'
    else
      html_to_return += '<li class="active">' + CGI::escapeHTML(dynamic_field_or_dynamic_field_group.display_label) + '</li>'
    end

    html_to_return += '</ol>'

    return html_to_return.html_safe
  end

end
