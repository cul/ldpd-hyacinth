module DigitalObject::IndexAndSearch::Index
  extend ActiveSupport::Concern

  #################
  # Solr Indexing #
  #################

  def to_solr
    flattened_dynamic_field_data = get_flattened_dynamic_field_data(true)

    object_as_json = to_json

    doc = {
      pid: pid,
      identifiers_sim: identifiers,
      title_ssm: get_title(placeholder_if_blank: true),
      sort_title_ssort: get_sort_title,
      parent_digital_object_pids_ssm: parent_digital_object_pids,
      parent_digital_object_pids_sim: parent_digital_object_pids,
      ordered_child_digital_object_pids_ssm: ordered_child_digital_object_pids,
      ordered_child_digital_object_pids_sim: ordered_child_digital_object_pids,
      number_of_ordered_child_digital_object_pids_ssm: ordered_child_digital_object_pids.length,
      number_of_ordered_child_digital_object_pids_sim: ordered_child_digital_object_pids.length,
      has_child_digital_objects_bi: ordered_child_digital_object_pids.length > 0,
      hyacinth_type_sim: digital_object_type.string_key,
      hyacinth_type_ssm: digital_object_type.string_key,
      state_sim: state,
      state_ssm: state,
      digital_object_type_display_label_sim: digital_object_type.display_label,
      digital_object_type_display_label_ssm: digital_object_type.display_label,
      project_string_key_sim: project.string_key,
      project_pid_sim: project.pid,
      project_pid_ssm: project.pid,
      project_display_label_sim: project.display_label,
      project_display_label_ssm: project.display_label,
      digital_object_data_ts: object_as_json
    }

    pub_target_data = publish_target_data
    doc[:publish_target_pid_sim] = pub_target_data.map { |data| data['pid'] }
    doc[:publish_target_pid_ssm] = pub_target_data.map { |data| data['pid'] }
    doc[:publish_target_display_label_sim] = pub_target_data.map { |data| data['display_label'] }
    doc[:publish_target_string_key_sim] = pub_target_data.map { |data| data['string_key'] }

    doc[:search_keyword_teim] = []
    doc[:search_identifier_sim] = []
    doc[:search_title_teim] = []

    # Special indexing rules for title field and non-dynamic fields

    doc[:search_identifier_sim] << pid
    doc[:search_identifier_sim].push(*identifiers) # Also append all identifiers to the array
    doc[:search_keyword_teim] << pid

    if flattened_dynamic_field_data.present?
      add_dynamic_field_data(doc, flattened_dynamic_field_data)
    else
      doc[:flattened_dynamic_field_data_ssm] = {}
    end

    doc[:dc_type_ssm] = dc_type # Store dc_type for all records, assets or not

    # Special indexing additions for Assets
    if self.is_a?(DigitalObject::Asset)
      doc[:asset_dc_type_sim] = dc_type # This is a special Asset-only facet field
    end

    doc
  end

  def add_dynamic_field_data(doc, flattened_dynamic_field_data)
    # Go through dynamic fields and find out which ones are:
    # - keyword searchable
    # - searchable identifier fields
    # - facet fields OR single_field_searchable fields
    doc[:flattened_dynamic_field_data_ssm] = flattened_dynamic_field_data.to_json # This is kept here for caching/performance purposes, flat display of any field without having to check with Fedora.
    ::DynamicField.where(string_key: flattened_dynamic_field_data.keys).find_each do |dynamic_field|
      values = flattened_dynamic_field_data[dynamic_field.string_key]

      doc[:search_keyword_teim] << values.join(' ') if dynamic_field.is_keyword_searchable
      doc[:search_identifier_sim] += values if dynamic_field.is_searchable_identifier_field
      doc[:search_title_teim] << values.join(' ') if dynamic_field.is_searchable_title_field

      doc['df_' + dynamic_field.string_key + '_sim'] = values if dynamic_field.is_facet_field || dynamic_field.is_single_field_searchable
    end
  end

  def update_index(commit = true)
    doc = to_solr
    Hyacinth::Utils::SolrUtils.solr.add(doc)
    Hyacinth::Utils::SolrUtils.solr.commit if commit
  end
end
