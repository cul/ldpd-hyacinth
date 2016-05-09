module DigitalObject::IndexAndSearch
  extend ActiveSupport::Concern

  included do
    include Index
    include SolrParams
  end

  module ClassMethods
    ###############
    # Solr Search #
    ###############

    # Iterates through search results, performing searches in batches behind the scenes.  Useful when reading from large datasets (e.g. for CSV export).
    # - Does not return facets
    # - Ignores 'per_page' and 'page' keys given in search_params (because we're returning all results in batches)
    def search_in_batches(search_params, user_for_permission_context, batch_size)
      search_params['per_page'] = batch_size
      search_params['page'] = 1

      loop do
        search_result_batch = search(search_params, false, user_for_permission_context)
        if search_result_batch['results'].blank?
          break
        else
          search_result_batch['results'].each do |solr_doc|
            yield JSON.parse(solr_doc['digital_object_data_ss'])
          end
          search_params['page'] += 1
        end
      end
    end

    def search(user_search_params = {}, facet_params = {}, user_for_permission_context = nil)
      per_page = user_search_params['per_page'].present? ? user_search_params['per_page'].to_i : 20
      page = user_search_params['page'].present? ? user_search_params['page'].to_i : 1
      # Allow specific result start values, but default to beginning of page
      start_value = user_search_params['start'].present? ? user_search_params['start'].to_i : (page - 1) * per_page

      solr_params = {}

      solr_params['rows'] = per_page
      solr_params['start'] = start_value
      solr_params['fq'] = []
      solr_params['q'] = user_search_params['q'] if user_search_params['q'].present?
      solr_params['qf'] = user_search_params.fetch('search_field', 'search_keyword_teim')
      solr_params['sort'] = user_search_params.fetch('sort', 'sort_title_ssort asc')
      solr_params['fl'] = user_search_params['fl'] if user_search_params['fl'].present?

      dynamic_field_string_keys_to_dynamic_fields = {}

      set_facet_params_for(facet_params, solr_params, dynamic_field_string_keys_to_dynamic_fields)

      set_filter_queries_for(user_search_params, solr_params)

      set_project_permission_filters_for(user_for_permission_context, solr_params)

      # Use post so we don't run into long query limits (limited by what solr's server will accept via GET)
      solr_response = Hyacinth::Utils::SolrUtils.solr.post('select', data: solr_params)

      Rails.logger.info('Solr Params: ' + solr_response['responseHeader']['params'].inspect)
      Rails.logger.debug('Solr Response: ' + solr_response.inspect)

      facet_data = FacetData.to_array(solr_response, dynamic_field_string_keys_to_dynamic_fields)

      {
        'search_time_in_millis' => solr_response['responseHeader']['QTime'],
        'total' => solr_response['response']['numFound'],
        'start' => solr_response['response']['start'],
        'page' => page,
        'per_page' => per_page,
        'results' => solr_response['response']['docs'],
        'facets' => facet_data
      }
    end

    def get_previous_and_next_in_search(current_result_number, search_params, user_for_permission_context = nil)
      previous_result_pid = nil
      next_result_pid = nil

      this_is_the_first_search_result = current_result_number == 0

      start = this_is_the_first_search_result ? 0 : current_result_number - 1
      rows = this_is_the_first_search_result ? 2 : 3 # per_page is the same as the solr 'rows' parameter

      search_params['start'] = start
      search_params['per_page'] = rows

      search_results = DigitalObject::Base.search(search_params, false, user_for_permission_context)

      if search_results['results'].length > 0
        if (current_result_number - 1) >= 0
          # We have a PREVIOUS result value
          previous_result_pid = search_results['results'].first['pid']
        end

        if search_results['total'] >= (start + rows)
          # We have a NEXT result value.
          next_result_pid = search_results['results'].last['pid']
        end
      end

      [previous_result_pid, next_result_pid, search_results['total']]
    end
  end
end
