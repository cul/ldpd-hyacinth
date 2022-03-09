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

          solr.post(handler, params: params)
        end

        # Batch lookup of terms by vocabulary and uri combination. The hash should be
        # vocabulary string keys mapped to an array of uris.
        #
        # @param [Hash<String, Array<String>>] terms_to_lookup
        # @return [Array<Hash>] An array of solr term documents.
        def batch_find(terms_to_lookup)
          search_query = terms_to_lookup.map { |vocab, uris|
            uri_query = uris.compact.uniq.map { |u| "\"#{u}\"" }.join(' OR ')
            "(vocabulary:\"#{vocab}\" AND uri:(#{uri_query}))"
          }.join(' OR ')

          start = 0
          count = 100
          docs = []
          loop do
            response = search do |params|
              params.q(search_query, false)
              params.start(start)
              params.rows(count)
              start += count
            end
            break if response['response']['docs'].empty?
            docs.concat(response['response']['docs'])
          end

          docs
        end

        def delete(uid)
          solr.delete("uid: #{::Solr::Utils.escape(uid)}")
        end
      end
    end
  end
end
