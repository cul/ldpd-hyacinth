module DigitalObject::IndexAndSearch::FacetData
  FACET_DISPLAY_LABELS = {
    'project_display_label_sim' => 'Project',
    'enabled_publish_target_display_label_sim' => 'Publish Target',
    'digital_object_type_display_label_sim' => 'Digital Object Type',
    'asset_dc_type_sim' => 'Asset Type',
    'has_child_digital_objects_bi' => 'Has Child Digital Objects?'
  }

  def self.to_array(facet_params, solr_response, dynamic_field_string_keys_to_dynamic_fields)
    # Convert facet data to nice, more useful form
    facet_sort = facet_params.fetch('sort', 'index')
    facet_limit = facet_params.fetch('per_page', 10).to_i
    facet_data = []

    if solr_response['facet_counts'].present? && solr_response['facet_counts']['facet_fields'].present?
      solr_response['facet_counts']['facet_fields'].each do |solr_field_name, values_and_counts|
        # Special handling for special field facet display labels
        #  Default to use user-configured display labels set for dynamic_field facet labels
        display_label = FACET_DISPLAY_LABELS[solr_field_name] || dynamic_field_string_keys_to_dynamic_fields[solr_field_name.gsub(/^df_/, '').gsub(/_sim$/, '')].standalone_field_label

        facet_values_and_counts = []
        counter = 0
        more_available = false
        values_and_counts.each_slice(2) do |slice|
          if counter < facet_limit
            facet_values_and_counts << { value: slice[0], count: slice[1] }
          else
            more_available = true
            break
          end
          counter += 1
        end

        facet_data << {
          facet_field_name: solr_field_name,
          display_label: display_label,
          values: facet_values_and_counts,
          more_available: more_available,
          sort: facet_sort
        }
      end
    end
    facet_data
  end
end
