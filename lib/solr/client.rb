# frozen_string_literal: true

module Solr
  class Client
    # Boolean to optionally commit changes to solr immediately after they are made.
    #
    # Solr instances are generally configured to automatically soft commit and then commit all changes. This keeps things
    # running smoothly in production environments because it prevents frequent, unnecessary commits to Solr. In other environments
    # this isn't always ideal.
    #
    # @return [Boolean] optionally sends commit message to solr after a change, defaults to false
    attr_accessor :commit_after_change

    # @return [RSolr::Client] connection to solr
    attr_reader :connection

    delegate :get, :post, :commit, to: :connection

    def initialize(config)
      url = config[:url]
      raise ArgumentError, 'url is required to create Solr::Connection' unless url
      @commit_after_change = config[:commit_after_change] || false
      @connection ||= ::RSolr.connect(url: url)
    end

    # TODO: this method might belong in the adapter
    # # Solr query. Returns solr json.
    # def search
    #   search_parameters = Params.new
    #
    #   # TODO: Potentially configure default rows
    #
    #   yield(search_parameters)
    #
    #   params = search_parameters.to_h
    #
    #   # If making a search use the /search handler otherwise use /select. /select
    #   # queries with just filters are faster than /search queries.
    #   handler = (params[:q].blank?) ? 'select' : 'search'
    #
    #   connection.get(handler, params: params)
    # end

    # Add document
    #
    # @param Hash json document to be added to solr
    def add(doc)
      connection.add(doc)
      connection.commit if commit_after_change
    end

    # Deleting term based on query
    #
    # @param String query
    def delete(q)
      connection.delete_by_query(q)
      connection.commit if commit_after_change
    end

    def clear
      connection.delete_by_query('*:*')
      connection.commit if commit_after_change
    end
  end
end
