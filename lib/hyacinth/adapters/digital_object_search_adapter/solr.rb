# frozen_string_literal: true

module Hyacinth
  module Adapters
    module DigitalObjectSearchAdapter
      class Solr < Abstract
        attr_reader :solr, :document_generator
        delegate :solr_document_for, to: :document_generator

        def initialize(adapter_config = {})
          super(adapter_config)
          @solr = ::Solr::Client.new(adapter_config)
          @document_generator = DocumentGenerator.new
        end

        def index(digital_object, **opts)
          solr.add(solr_document_for(digital_object))
          solr.commit if opts[:commit]

          # TODO: index presence or absence of field values, even if the field itself isn't indexed for search
        end

        def remove(digital_object, **opts)
          solr.delete("id: #{::Solr::Utils.escape(digital_object.uid)}")
          solr.commit if opts[:commit]
        end

        def search(search_params = {}, user_for_permission_context = nil)
          solr_parameters = solr_params_for(search_params)

          # If a user_for_permission_context has been provided, limit search results to objects
          # in projects that are readable for that user.
          apply_user_project_filters(solr_parameters, user_for_permission_context) if user_for_permission_context

          yield(solr_parameters) if block_given?

          params = solr_parameters.to_h

          # If making a search use the /search handler otherwise use /select. /select
          # queries with just filters are faster than /search queries.
          handler = params[:q].blank? ? 'select' : 'search'

          solr.get(handler, params: params)
        end

        def solr_params_for(search_params)
          solr_parameters = ::Solr::Params.new
          solr_parameters.tap do |sp|
            # Only return active objects
            sp.fq('state_ssi', Hyacinth::DigitalObject::State::ACTIVE)

            # Apply search_params
            search_params.each do |k, v|
              if k.to_s == 'q'
                sp.q(v)
              elsif k.to_s == 'facet_on'
                Array(v).map { |eachv| sp.facet_on(eachv) }
              else
                Array(v).map { |eachv| sp.fq(k, eachv) }
              end
            end
          end
          solr_parameters
        end

        # Adds filter queries to the given solr_prameters based on projects where the
        # given user has read access.
        def apply_user_project_filters(solr_parameters, user)
          read_objects_access_project_string_keys = Project.accessible_by(Ability.new(user), :read_objects).map(&:string_key)
          if read_objects_access_project_string_keys.present?
            solr_parameters.fq('projects_ssim', read_objects_access_project_string_keys)
          else
            # User has no project permissions, so we'll deliberately put in an unresolvable value
            # to get zero results. Projects cannot have exclamation points in their string keys,
            # so the value below will work.
            solr_parameters.fq('projects_ssim', '!nomatch!')
          end
        end

        # Returns the uids associated with the given identifier
        # @param identifier
        # @param opts
        #        opts[:retry_with_delay] If no results are found, search again after the specified delay (in seconds).
        def identifier_to_uids(identifier, opts = {})
          2.times do
            results = search do |params|
              params.fq('identifier_ssim', identifier)
            end

            results['response']['docs'].map { |doc| doc['id'] } if results['response']['numFound'].positive?

            if opts[:retry_with_delay].present?
              sleep opts[:retry_with_delay]
            else
              break
            end
          end
        end

        # Deletes all records from the search index
        def clear_index
          solr.clear
        end
      end
    end
  end
end
