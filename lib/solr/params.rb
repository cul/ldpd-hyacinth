# frozen_string_literal: true

module Solr
  class Params
    attr_reader :parameters

    def initialize
      @parameters = {
        q: nil,
        qt: 'search',
        df: 'keywords_teim', # TODO: Is this actually the default we want? This class is used by the TermSearchAdapter too.
        fq: [],
        'facet.field'.to_sym => [],
        start: 0
      }
    end

    def fq(field, values, boolean_operator = :or)
      raise ArgumentError unless [:and, :or].include?(boolean_operator)
      escaped_values = Array.wrap(values).map { |value| Solr::Utils.escape(value).gsub(' ', '\ ') }
      @parameters[:fq] << "#{field}:(#{escaped_values.join(boolean_operator == :and ? ' AND ' : ' OR ')})" unless escaped_values.blank?
      self
    end

    def facet_on(field)
      @parameters[:"facet.field"] << field unless field.blank?
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

    def q(query, escape: true)
      if query.blank?
        @parameters[:q] = nil
        @parameters[:qt] = 'search'
      else
        @parameters[:q] = escape ? Solr::Utils.escape(query) : query
        @parameters[:qt] = 'select'
      end
      self
    end

    def to_h
      parameters[:"facet.field"].present? ? parameters.merge(facet: 'on') : parameters
    end
  end
end
