module DigitalObject::IndexAndSearch::SolrParams
  extend ActiveSupport::Concern

  module ClassMethods
    FILTER_QUERY_PROCS = {
      'present' => proc { |filter_field| filter_field + ':[* TO *]' },
      'absent' => proc { |filter_field| '-' + filter_field + ':["" TO *]' },
      'equals' => proc { |filter_field, safe_value| filter_field + ': ' + safe_value },
      'contains' => proc { |filter_field, safe_value| filter_field + ': *' + safe_value + '*' }
    }

    def set_project_permission_filters_for(user_for_permission_context, solr_params)
      return unless user_for_permission_context.present? && !user_for_permission_context.admin?
      user_allowed_projects = user_for_permission_context.projects
      if user_allowed_projects.length > 0
        project_clause = '"' + user_for_permission_context.projects.map(&:string_key).join('" OR "') + '"'
        solr_params['fq'] << "project_string_key_sim:(#{project_clause})"
      else
        # No projects. Return 0 rows from result set and return no facets.
        solr_params['rows'] = 0
        solr_params['facet'] = false
        # And guarantee no results with fq tat will return zero results
        solr_params['fq'] << 'hyacinth_type_sim:none'
      end
    end

    def set_facet_params_for(facet_params, solr_params, dynamic_field_string_keys_to_dynamic_fields)
      # facet_params are for specifying how you want to RECEIVE facets.
      # This has nothing to do with using the facet feature to apply facet filters.
      if facet_params.blank?
        solr_params['facet'] = false
      else
        if facet_params['field'].present?
          facet_fields = [facet_params['field']]
          faceted_field = ::DynamicField.find_by(string_key: (facet_params['field'].gsub(/^df_/, '').gsub(/_sim$/, '')))
          dynamic_field_string_keys_to_dynamic_fields[faceted_field.string_key] = faceted_field if faceted_field.present?
        else
          # Set up default facet fields
          facet_fields = []
          # Manually add certain non-dynamic-field facets
          facet_fields += ['digital_object_type_display_label_sim', 'project_display_label_sim', 'publish_target_display_label_sim', 'asset_dc_type_sim', 'has_child_digital_objects_bi']
          ::DynamicField.find_each do |dynamic_field|
            dynamic_field_string_keys_to_dynamic_fields[dynamic_field.string_key] = dynamic_field
            facet_fields << 'df_' + dynamic_field.string_key + '_sim' if dynamic_field.is_facet_field
          end
        end

        facet_limit = facet_params.fetch('per_page', 10).to_i
        facet_offset = (facet_params.fetch('page', 1).to_i - 1) * facet_limit
        facet_sort = facet_params.fetch('sort', 'index')

        solr_params['facet'] = true
        solr_params['facet.field'] = facet_fields
        solr_params['facet.sort'] = facet_sort
        solr_params['facet.limit'] = facet_limit + 1
        solr_params['facet.offset'] = facet_offset
      end
    end

    def set_filter_queries_for(user_search_params, solr_params)
      # Only retrieve active ('A') items
      solr_params['fq'] << 'state_sim:A'

      # Looking for specific set of PIDs
      solr_params['fq'] << 'pid:("' + user_search_params['pids'].join('" OR "') + '")' if user_search_params['pids'].present?

      # Add filters for currently applied facet filters, making sure to escape values
      user_search_params.fetch('f', {}).each do |facet_field, values|
        facet_clause = '"' + values.map { |value| Hyacinth::Utils::SolrUtils.solr_escape(value) }.join('" AND "') + '"'
        solr_params['fq'] << "#{facet_field}:(#{facet_clause})"
      end

      # Also add currently applied filters, building fq values based on "operator" values and making sure to escape values
      user_search_params.fetch('fq', {}).each do |filter_field, values|
        # Note: API values may be interpreted as a hash instead of a value.  This is handled.
        # Hash like this: {"0" => {"greater_than" => "something"}, "1" => {"less_than" => "something else"}}
        # Instead of the Array form: [{"greater_than" => "something"}, {"less_than" => "something else"}]
        (values.is_a?(Array) ? values : values.values).each do |operator_and_value|
          operator_and_value.each do |operator, value|
            # Wrap value in double quotes so we don't have to worry about other characters to escape (because they're in quotes)
            # All we need to do is escape quotes and backslashes
            safe_value = Hyacinth::Utils::SolrUtils.solr_escape(value.strip)

            raise "Unexpected operator: #{operator}" unless FILTER_QUERY_PROCS.key? operator

            solr_params['fq'] << FILTER_QUERY_PROCS[operator].call(filter_field, safe_value)
          end
        end
      end
    end
  end
end
