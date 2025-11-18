module Hyacinth::DigitalObjects::EditorBehavior
  def object_data_for_editor(digital_object)
    fieldsets = Fieldset.where(project: digital_object.project)
    enabled_dynamic_fields = digital_object.enabled_dynamic_fields

    dynamic_field_hierarchy = DynamicFieldGroupCategory.all # Get all DyanamicFieldGroupCategories (which recursively includes sub-dynamic_field_groups and dynamic_fields)
    dynamic_field_ids_to_enabled_dynamic_fields = Hash[enabled_dynamic_fields.map { |enabled_dynamic_field| [enabled_dynamic_field.dynamic_field_id, enabled_dynamic_field] }]

    data_for_editor_response = {
      digital_object: digital_object,
      dynamic_field_hierarchy: dynamic_field_hierarchy,
      fieldsets: fieldsets,
      dynamic_field_ids_to_enabled_dynamic_fields: dynamic_field_ids_to_enabled_dynamic_fields,
      allowed_publish_targets: digital_object.allowed_publish_targets,
      all_projects: Project.all.order(:display_label)
    }

    if digital_object.is_a?(DigitalObject::Asset)
      data_for_editor_response['player_url'] = digital_object.player_url(request.remote_ip)
    end

    if params['search_result_number'].present? && params['search'].present?
      current_result_number = params['search_result_number'].to_i
      search_params = params['search']

      previous_result_pid, next_result_pid, total_num_results = DigitalObject::Base.get_previous_and_next_in_search(current_result_number, search_params, current_user)

      data_for_editor_response['previous_and_next_data'] = {}
      data_for_editor_response['previous_and_next_data']['previous_pid'] = previous_result_pid
      data_for_editor_response['previous_and_next_data']['next_pid'] = next_result_pid
      data_for_editor_response['previous_and_next_data']['total_num_results'] = total_num_results
    end
    data_for_editor_response
  end

  def ordered_children_data_for_editor(digital_object)
    ordered_child_search_results = []

    if digital_object.ordered_child_digital_object_pids.present?
      child_pids = digital_object.ordered_child_digital_object_pids

      pids_to_search_results = {}
      search_response = DigitalObject::Base.search({ 'pids' => child_pids, 'per_page' => 99_999 }, current_user)
      if search_response['results'].present?
        search_response['results'].each do |result|
          pids_to_search_results[result['pid']] = result
        end
      end

      child_pids.each do |pid|
        ordered_child_search_results.push(pids_to_search_results[pid].present? ? pids_to_search_results[pid] : { 'pid' => pid, 'not_in_hyacinth' => true })
      end
    end

    {
      digital_object: digital_object,
      ordered_child_search_results: ordered_child_search_results,
      too_many_to_show: false # We are always showing all children.  Might change this later if this becomes a problem.
    }
  end
end
