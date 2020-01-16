# frozen_string_literal: true

module Solr
  class Params
    attr_reader :parameters

    def initialize
      @parameters = {
        q: nil,
        qt: 'search',
        fq: [],
        # rows: URIService::DEFAULT_LIMIT,
        start: 0
      }
    end

    def fq(field, value)
      @parameters[:fq] << "#{field}:\"#{Solr::Utils.escape(value)}\"" unless value.nil?
      self
    end

    def rows(num)
      @parameters[:rows] = num
      self
    end

    def start(num)
      @parameters[:start] = num
      self
    end

    def q(query)
      @parameters[:q] = Solr::Utils.escape(query) unless query.nil?
      self
    end

    def to_h
      parameters
    end
  end
end
