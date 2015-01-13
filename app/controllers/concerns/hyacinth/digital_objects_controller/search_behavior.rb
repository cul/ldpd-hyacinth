module Hyacinth::DigitalObjectsController::SearchBehavior
  extend ActiveSupport::Concern

  DEFAULT_PER_PAGE = 20

  def apply_default_search_params
    params[:sort_by] = 'sort_title__asc' if params[:sort_by].blank?
  end

  # Note: This method should NOT modify the passed user_search_params variable
  # Note: The last two params () only apply when do_pagination == false
  # A value of -1 for max_number_of_docs_to_return means "return all docs"
  def do_search(user_search_params, return_facets_for_result_set, do_pagination, return_facets=false, result_number_to_start_at=0, max_number_of_docs_to_return=-1)

    max_number_of_docs_to_return = max_number_of_docs_to_return.to_i

    return DigitalObject.search do

      with(:is_deleted, false)

      # Potentially limit search to certain projects
      unless current_user.is_admin?
        # If this user is not an admin, restrict searches to projects that this user has access to
        string_keys_of_projects_that_this_user_has_access_to = current_user.project_permissions.map{|project_permission|project_permission.project.string_key}
        unless string_keys_of_projects_that_this_user_has_access_to.blank?
          with(:project_string_key, string_keys_of_projects_that_this_user_has_access_to)
        else
          with(:project_string_key, nil)
        end
      end

      # Digital Object Type (special exclusion facet)
      if user_search_params[:digital_object_type].present?
        digital_object_type_filter = with(:digital_object_type, user_search_params[:digital_object_type])
        facet :digital_object_type, exclude: [digital_object_type_filter]
      end

      # Sort order
      if user_search_params[:sort_by].present?
        split_value = user_search_params[:sort_by].split('__')
        sort_by_field = split_value[0]
        sort_direction = split_value[1]
        order_by sort_by_field.to_sym, sort_direction.to_sym
      end

      # Pagination
      if do_pagination

        per_page = DEFAULT_PER_PAGE # default
        page = 1 # default

        # Results per page
        if ! user_search_params[:per_page].blank? && DigitalObject::RESULTS_PER_PAGE_OPTIONS.include?(user_search_params[:per_page].to_i)
          per_page = user_search_params[:per_page]
        end

        # Page
        if ! user_search_params[:page].blank?
          page = user_search_params[:page]
        end

        paginate :page => page.to_i, :per_page => per_page.to_i
      end

      # Handle various search types
      if ! user_search_params[:q].blank?
        if user_search_params[:search_type].blank? || user_search_params[:search_type] == 'fulltext'
          fulltext user_search_params[:q]
        else
          with(user_search_params[:search_type].to_sym, user_search_params[:q])
        end
      end

      # Apply current facets
      if user_search_params[:f] && user_search_params[:f].length > 0
        user_search_params[:f].each {|facet_field, facet_values|

          facet_values.each {|facet_value|
            with((facet_field + '_facet').to_sym, facet_value)
          }
        }
      end

      # Perform faceting on current result set
      if return_facets_for_result_set
        DigitalObject::get_indexing_rules['facet'].each do |field_name, options|
          facet((field_name + '_facet').to_sym)
        end
      end

      # Do raw solr parameter adjustment as needed
      adjust_solr_params do |raw_solr_params|
        # Let's force edismax (instead of the default dismax) so that we can do wildcard searches
        raw_solr_params[:defType] = 'edismax'

        # In the case of CSV exports (which is when do_pagination would generally == false), we want a really really high limit to return all results when we're not paginating.
        # This is actually the recommended practice for returning all rows.  From http://wiki.apache.org/solr/CommonQueryParameters:
        # "The default value is "10", which is used if the parameter is not specified. If you want to
        # tell Solr to return all possible results from the query without an upper bound, specify rows
        # to be 10000000 or some other ridiculously large value that is higher than the possible number
        # of rows that are expected."
        if ! do_pagination

          raw_solr_params[:start] = result_number_to_start_at.to_i

          if max_number_of_docs_to_return == -1
            raw_solr_params[:rows] = 100000000
          else
            raw_solr_params[:rows] = max_number_of_docs_to_return.to_i
          end

        end

      end

    end
  end

  # Returns two variables: previous_digital_object_url and next_digital_object_url
  def get_previous_and_next_digital_object_urls(search_params, search_result_counter)

    additional_search_preservation_link_params = {}
    additional_search_preservation_link_params[:search_params_string] = params[:search_params_string] if params[:search_params_string]

    search_result_counter = search_result_counter.to_i

    previous_digital_object_url = nil
    next_digital_object_url = nil

    if search_result_counter == 0
      # Then we're starting at row == 0 and only returning a next_digital_object_url since there is no previous digital_object
      digital_object_search = do_search(search_params, false, false, false, 0, 2)
      if digital_object_search.hits.length == 2
        # There is more than one result in this result set, so we have a valid next_digital_object_url to return
        additional_search_preservation_link_params[:search_result_counter] = (params[:search_result_counter].to_i+1) if params[:search_result_counter] # Increment search_result_counter (if present) for the next_digital_object_url
        next_digital_object_url = digital_object_url(digital_object_search.results[1].id, additional_search_preservation_link_params)
      end
    else
      digital_object_search = do_search(search_params, false, false, false, (search_result_counter-1), 3)
      if digital_object_search.hits.length > 1
        # At the very least, we've got the previous digital_object and the current digital_object.  We can generate the previous_digital_object_url
        additional_search_preservation_link_params[:search_result_counter] = (params[:search_result_counter].to_i-1) if params[:search_result_counter] # Decrement search_result_counter (if present) for the next_digital_object_url
        previous_digital_object_url = digital_object_url(digital_object_search.results[0].id, additional_search_preservation_link_params)
      end
      if digital_object_search.hits.length == 3
        # Since we have three returned digital_object, we've got the previous digital_object, the current digital_object and the next digital_object.  We can generate the next_digital_object_url.
        additional_search_preservation_link_params[:search_result_counter] = (params[:search_result_counter].to_i+1) if params[:search_result_counter] # Increment search_result_counter (if present) for the next_digital_object_url
        next_digital_object_url = digital_object_url(digital_object_search.results[2].id, additional_search_preservation_link_params)
      end

    end

    return previous_digital_object_url, next_digital_object_url

  end

end
