module ProjectsHelper

  def do_recursive_enabled_dynamic_field_render(project_form_builder, digital_object_type, dynamic_field_or_dynamic_field_group)

    html_to_return = ''

    if dynamic_field_or_dynamic_field_group.is_a?(DynamicField)
      project_object = project_form_builder.object
      html_to_return += '<div class="enabled_dynamic_field_row">'
      html_to_return += '<div class="row">'

      html_to_return += '<div class="col-md-2"><span class="label label-info" title="' + CGI::escapeHTML(dynamic_field_or_dynamic_field_group.string_key) + '">' + CGI::escapeHTML(dynamic_field_or_dynamic_field_group.display_label) + '</span></div>'

      enabled_dynamic_field = project_object.enabled_dynamic_fields.find { |o| o.dynamic_field == dynamic_field_or_dynamic_field_group && o.digital_object_type == digital_object_type } || project_object.enabled_dynamic_fields.build(dynamic_field: dynamic_field_or_dynamic_field_group, digital_object_type: digital_object_type)

      project_form_builder.fields_for(:enabled_dynamic_fields, enabled_dynamic_field) do |enabled_dynamic_field_form|

        dynamic_field = enabled_dynamic_field_form.object.dynamic_field

        html_to_return += enabled_dynamic_field_form.hidden_field(:id) if enabled_dynamic_field.id.present?
        html_to_return += enabled_dynamic_field_form.hidden_field(:dynamic_field_id) + enabled_dynamic_field_form.hidden_field(:digital_object_type_id)
        html_to_return += '<div class="col-md-1 check-stack">
          <div class="checkbox"><label>' + enabled_dynamic_field_form.check_box(:_destroy, {checked: enabled_dynamic_field.id.present?}, '0', '1') + ' Enabled</label></div>
          <div class="checkbox"><label>' + enabled_dynamic_field_form.check_box(:required) + ' Required</label></div>
          </div>'
        html_to_return += '<div class="col-md-1 check-stack">
          <div class="checkbox"><label>' + enabled_dynamic_field_form.check_box(:locked) + ' Locked</label></div>
          <div class="checkbox"><label>' + enabled_dynamic_field_form.check_box(:hidden) + ' Hidden</label></div>
        </div>'
        # TODO: Do we actually need the only_save_dynamic_field_group_if_present feature?
        #html_to_return += '<div class="col-md-2 check-stack">
        #  <div class="checkbox"><label>' + enabled_dynamic_field_form.check_box(:only_save_dynamic_field_group_if_present) + ' Only save field group if this field is present</label></div>
        #</div>'
        html_to_return += '<div class="col-md-4">' + enabled_dynamic_field_form.send((dynamic_field.dynamic_field_type == DynamicField::Type::TEXTAREA ? 'text_area' : 'text_field'), :default_value, class: 'form-control', placeholder: 'Default value (optional)') + '</div>'
        fieldsets = Fieldset.where(project: project_object)
        if fieldsets.present?
          html_to_return += '<div class="col-md-4">' + enabled_dynamic_field_form.collection_select(:fieldset_ids, fieldsets, :id, :display_label, {}, class: 'form-control multiselect', :'data-multiselect-nonselected-text' => '- No fieldsets selected -', multiple: true) + '</div>'
        end
      end
      html_to_return += '<div class="clearfix"></div></div></div>'
      return html_to_return.html_safe
    elsif
      html_to_return += '<div class="enabled_dynamic_field_row">'
      html_to_return += '<h4 class="dynamic_field_group_label"><span class="label label-info">' + CGI::escapeHTML(dynamic_field_or_dynamic_field_group.display_label) + '</span></h4>'
      html_to_return += '<div class="indent">'

      dynamic_field_or_dynamic_field_group.get_child_dynamic_fields_and_dynamic_field_groups.each do |child_dynamic_field_or_dynamic_field_group|
        html_to_return += do_recursive_enabled_dynamic_field_render(project_form_builder, digital_object_type, child_dynamic_field_or_dynamic_field_group)
      end
      html_to_return += '</div>'
      html_to_return += '</div>'
      return html_to_return.html_safe
    end

  end

end
