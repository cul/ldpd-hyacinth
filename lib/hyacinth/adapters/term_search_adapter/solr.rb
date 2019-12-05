# frozen_string_literal: true

module Hyacinth
  module Adapters
    module TermSearchAdapter
      class Solr
        attr_reader :solr

        delegate :add, :clear, to: :solr

        def initialize(adapter_config = {})
          @solr = ::Solr::Client.new(adapter_config)
        end

        # Look up term
        #
        # @param String vocabulary vocabulary string key
        # @param String uri
        # @return nil if no matching term found
        # @return Hash if matching term found
        def find(vocabulary, uri)
          results = search do |params|
            params.fq('vocabulary', vocabulary)
            params.fq('uri', uri)
          end

          case results['response']['numFound']
          when 0
            nil
          when 1
            results['response']['docs'].first
          else
            raise 'More than one term document matched uri'
          end
        end

        # Solr query. Returns solr json.
        def search
          search_parameters = ::Solr::Params.new

          yield(search_parameters)

          params = search_parameters.to_h

          # If making a search use the /search handler otherwise use /select. /select
          # queries with just filters are faster than /search queries.
          handler = params[:q].blank? ? 'select' : 'search'

          solr.get(handler, params: params)
        end

        def delete(uid)
          solr.delete("uid: #{::Solr::Utils.escape(uid)}")
        end
      end
    end
  end
end
