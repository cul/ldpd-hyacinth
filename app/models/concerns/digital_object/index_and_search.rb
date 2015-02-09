module DigitalObject::IndexAndSearch
  extend ActiveSupport::Concern

  LUCENE_SPECIAL_CHARACTERS_TO_ESCAPE_EXCLUDING_BACKSLASH = ['+', '-', '&&', '||', '!', '(', ')', '{', '}', '[', ']', '^', '"', '~', '*', '?', ':', '/']

  #################
  # Solr Indexing #
  #################

  def to_solr

    flattened_dynamic_field_data = get_flattened_dynamic_field_data(true)

    doc = {
      pid: self.pid,
      title_ssm: self.get_title,
      parent_digital_object_pids_ssm: self.parent_digital_object_pids,
      parent_digital_object_pids_sim: self.parent_digital_object_pids,
      ordered_child_digital_object_pids_ssm: self.ordered_child_digital_object_pids,
      ordered_child_digital_object_pids_sim: self.ordered_child_digital_object_pids,
      number_of_ordered_child_digital_object_pids_ssm: self.ordered_child_digital_object_pids.length,
      number_of_ordered_child_digital_object_pids_sim: self.ordered_child_digital_object_pids.length,
      sort_title_ssort: self.get_sort_title,
      hyacinth_type_sim: digital_object_type.string_key,
      hyacinth_type_ssm: digital_object_type.string_key,
      state_sim: self.state,
      state_ssm: self.state,
      digital_object_type_display_label_sim: self.digital_object_type.display_label,
      digital_object_type_display_label_ssm: self.digital_object_type.display_label,
      project_string_key_sim: self.projects.map{|project|project.string_key},
      flattened_dynamic_field_data_ssm: flattened_dynamic_field_data.to_json # This is kept here for caching/performance purposes, flat display of any field without having to check with Fedora.
    }

    project_display_labels = self.projects.map{|project|project.display_label}
    doc[:project_display_label_sim] = project_display_labels
    doc[:project_display_label_ssm] = project_display_labels

    search_keyword_teim = []
    search_identifier_sim = []
    search_title_teim = []

    # Special indexing rules for title field and non-dynamic fields
    search_identifier_sim << self.pid
    search_keyword_teim << self.pid

    # Go through dynamic fields and find out which ones are:
    # - keyword searchable
    # - searchable identifier fields
    # - facet fields OR single_field_searchable fields
    if flattened_dynamic_field_data.present?
      ::DynamicField.where(string_key: flattened_dynamic_field_data.keys).each do |dynamic_field|
        values = flattened_dynamic_field_data[dynamic_field.string_key]

        search_keyword_teim << values.join(' ') if dynamic_field.is_keyword_searchable
        search_identifier_sim += values if dynamic_field.is_searchable_identifier_field
        search_title_teim << values.join(' ') if dynamic_field.is_searchable_title_field

        doc['df_' + dynamic_field.string_key + '_sim'] = values if dynamic_field.is_facet_field || dynamic_field.is_single_field_searchable
      end
    end

    doc[:search_keyword_teim] = search_keyword_teim
    doc[:search_identifier_sim] = search_identifier_sim
    doc[:search_title_teim] = search_title_teim

    doc[:dc_type_ssm] = self.dc_type # Store dc_type for all records, assets or not

    # Special indexing additions for Assets
    if self.is_a?(DigitalObject::Asset)
      doc[:asset_dc_type_sim] = self.dc_type # This is a special Asset-only facet field
    end

    return doc

  end

  def update_index(commit=true)
    doc = self.to_solr
    Hyacinth::Utils::SolrUtils.solr.add(doc)
    Hyacinth::Utils::SolrUtils.solr.commit if commit
  end

  module ClassMethods

    ###############
    # Solr Search #
    ###############

    def search(user_search_params = {}, facet_params = {})

      per_page = user_search_params['per_page'].present? ? user_search_params['per_page'].to_i : 20
      page = user_search_params['page'].present? ? user_search_params['page'].to_i : 1
      manually_selected_start_value = user_search_params['start'].present? ? user_search_params['start'].to_i : nil

      dynamic_field_string_keys_to_dynamic_fields = {}
      facet_fields = []

      # Manually add Digital Object Type, Project and Asset Type facets in first positions
      facet_fields << ['digital_object_type_display_label_sim', 'project_display_label_sim', 'asset_dc_type_sim']

      ::DynamicField.all.each {|dynamic_field|
        dynamic_field_string_keys_to_dynamic_fields[dynamic_field.string_key] = dynamic_field
        facet_fields << 'df_' + dynamic_field.string_key + '_sim' if dynamic_field.is_facet_field
      }

      solr_params = {}

      solr_params['rows'] = per_page
      if manually_selected_start_value.present?
        solr_params['start'] = manually_selected_start_value # Allow specific result start values
      else
        solr_params['start'] = (page - 1) * per_page # Default to page-based start values, unless specific start value is specified
      end
      solr_params['fq'] = []
      solr_params['q'] = user_search_params[:q] if user_search_params[:q].present?
      solr_params['qf'] = user_search_params[:search_field] || 'search_keyword_teim'
      solr_params['sort'] = user_search_params[:sort] || 'sort_title_ssort asc'

      # Only retrieve active ('A') items
      solr_params['fq'] << 'state_sim:A'

      # Facet preferences (if faceting is enabled)
      facet_limit = 10 # default
      facet_offset = 0 # default
      facet_sort = 'index' # default

      # facet_params are for specifying how you want to RECEIVE facets.
      # This has nothing to do with using the facet feature to apply facet filters.
      unless facet_params.to_s == "false"
        facet_fields = facet_params['field'] if facet_params['field'].present?
        facet_limit = facet_params['per_page'].to_i if facet_params['per_page'].present?
        facet_offset = (facet_params['page'].to_i - 1) * facet_limit if facet_params['page'].present?
        facet_sort = facet_params['sort'] if facet_params['sort'].present?

        solr_params['facet'] = true
        solr_params['facet.field'] = facet_fields
        solr_params['facet.sort'] = facet_sort
        solr_params['facet.limit'] = facet_limit + 1
        solr_params['facet.offset'] = facet_offset
      else
        solr_params['facet'] = false
      end

      # Add filters for currently applied facet filters, making sure to escape values
      if user_search_params[:f].present?
        user_search_params[:f].each do |facet_field, values|
          #match = ['+', '-', '&', '|', '!', '(', ')', '{', '}', '[', ']', '^', '~', '*', '?', ':', '"', ';', ' '];
          #next_fq = facet_field + ': ("' + values.map{|value| match.each{|o| value.gsub!(o, '\\' + o)}; value }.join('" AND "') + '")'

          # Wrap value in double quotes so we don't have to worry about other characters to escape (because they're in quotes)
          # All we need to do is escape quotes and backslashes

          next_fq = facet_field + ': ("' + values.map{|value| value.gsub('\\', '\\\\\\').gsub('"', '\\"') }.join('" AND "') + '")'
          solr_params['fq'] << next_fq
        end
      end

      # Also add currently applied filters, building fq values based on "operator" values and making sure to escape values
      if user_search_params[:fq].present?
        user_search_params[:fq].each do |filter_field, values|

          # Note: API values may be interpreted as a hash instead of a value.  This is handled.
          # Hash like this: {"0" => {"greater_than" => "something"}, "1" => {"less_than" => "something else"}}
          # Instead of the Array form: [{"greater_than" => "something"}, {"less_than" => "something else"}]
          (values.is_a?(Array) ? values : values.values).each do |operator_and_value|
            operator_and_value.each do |operator, value|

              # Wrap value in double quotes so we don't have to worry about other characters to escape (because they're in quotes)
              # All we need to do is escape quotes and backslashes
              safe_value = '"' + value.gsub('\\', '\\\\\\').gsub('"', '\\"') + '"'

              if operator == 'present'
                next_fq = filter_field + ':[* TO *]'
              elsif operator == 'absent'
                next_fq = '-' + filter_field + ':["" TO *]'
              elsif operator == 'equals'
                next_fq = filter_field + ': ' + safe_value
              else
                raise 'Unexpected operator: ' + operator
              end

              solr_params['fq'] << next_fq
            end
          end

        end
      end

      solr_response = Hyacinth::Utils::SolrUtils.solr.get('select', params: solr_params)

      Rails.logger.debug('Solr Params: ' + solr_response['responseHeader']['params'].inspect)
      Rails.logger.debug('Solr Response: ' + solr_response.inspect)

      # Convert facet data to nice, more useful form
      facet_data = []
      if solr_response['facet_counts'].present?  && solr_response['facet_counts']['facet_fields'].present?

        solr_response['facet_counts']['facet_fields'].each {|solr_field_name, values_and_counts|

          # Special handling for special field facet display labels
          if solr_field_name == 'project_display_label_sim'
            display_label = 'Project'
          elsif solr_field_name == 'digital_object_type_display_label_sim'
            display_label = 'Digital Object Type'
          elsif solr_field_name == 'asset_dc_type_sim'
            display_label = 'Asset Type'
          else
            # Use user-configured display labels set for dynamic_field facet labels
            display_label = dynamic_field_string_keys_to_dynamic_fields[solr_field_name.gsub(/^df_/, '').gsub(/_sim$/, '')].standalone_field_label
          end

          facet_values_and_counts = []
          counter = 0
          more_available = false
          values_and_counts.each_slice(2) do |slice|

            if counter < facet_limit
              facet_values_and_counts << {value: slice[0], count: slice[1]}
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
        }
      end

      return {
        'search_time_in_millis' => solr_response['responseHeader']['QTime'],
        'total' => solr_response['response']['numFound'],
        'start' => solr_response['response']['start'],
        'page' => page,
        'per_page' => per_page,
        'results' => solr_response['response']['docs'],
        'facets' => facet_data
      }

    end

    def get_previous_and_next_in_search(current_result_number, search_params)

      previous_result_pid = nil
      next_result_pid = nil

      this_is_the_first_search_result = current_result_number == 0

      start = this_is_the_first_search_result ? 0 : current_result_number - 1
      rows = this_is_the_first_search_result ? 2 : 3 # per_page is the same as the solr 'rows' parameter

      search_params['start'] = start
      search_params['per_page'] = rows

      search_results = DigitalObject::Base.search(search_params, false)

      if search_results['results'].length > 0
        if(current_result_number - 1 >= 0)
          # We have a PREVIOUS result value
          previous_result_pid = search_results['results'].first['pid']
        end

        if(search_results['total'] >= start + rows)
          # We have a NEXT result value.
          next_result_pid = search_results['results'].last['pid']
        end
      end

      return previous_result_pid, next_result_pid, search_results['total']

    end


  end

end
