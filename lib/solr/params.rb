# frozen_string_literal: true

module Solr
  class Params
    attr_reader :parameters

    FILTER_VALUE_JOINER = ' OR '
    VALID_FILTER_MATCHES = {
      'CONTAINS' => { field_template: '%s:(%s)', value_template: '*%s*' },
      'DOES_NOT_CONTAIN' => { field_template: '-%s:(%s)', value_template: '*%s*' },
      'DOES_NOT_EQUAL' => { field_template: '-%s:(%s)' },
      'DOES_NOT_EXIST' => { field_template: '-%s:%s', value: '*' },
      'DOES_NOT_START_WITH' => { field_template: '-%s:(%s)', value_template: '%s*' },
      'EQUALS' => { field_template: '%s:(%s)' },
      'EXISTS' => { field_template: '%s:%s', value: '*' },
      'STARTS_WITH' => { field_template: '%s:(%s)', value_template: '%s*' }
    }.freeze
    VALID_SORT_DIRECTION = ['asc', 'desc'].freeze

    def initialize
      @parameters = {
        q: nil,
        fq: [],
        'facet.field'.to_sym => [],
        start: 0,
        'facet.mincount': 1 # TODO: Check to make sure this is okay as a global default for digital objects and terms.
      }
    end

    def fq(field, value_or_values, match_operator = 'EQUALS')
      raise(ArgumentError, "Invalid match operator: #{match_operator}") unless VALID_FILTER_MATCHES.include?(match_operator)
      escaped_values = Array.wrap(value_or_values).map { |value| Solr::Utils.escape(value, true) }
      filter_data = VALID_FILTER_MATCHES[match_operator]
      value = filter_data[:value] || escaped_values.map { |ev| filter_data[:value_template]&.%(ev) || ev }.join(FILTER_VALUE_JOINER)
      @parameters[:fq] << format(filter_data[:field_template], field, value) unless value.blank?
      self
    end

    def facet_on(field)
      @parameters[:"facet.field"] << field unless field.blank?
      yield FacetProxy.new(field, self) if block_given?
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
      else
        @parameters[:q] = escape ? Solr::Utils.escape(query) : query
      end
      self
    end

    def default_field(field)
      @parameters[:df] = field
      self
    end

    def raw_parameter(key, value)
      @parameters[key.to_sym] = value
      self
    end

    def sort(field, direction)
      raise ArgumentError, "direction must be one of #{VALID_SORT_DIRECTION.join(', ')}, instead got '#{direction}'" unless VALID_SORT_DIRECTION.include?(direction)

      @parameters[:sort] = "#{field} #{direction}"
      self
    end

    def to_h
      parameters[:"facet.field"].present? ? parameters.merge(facet: 'on') : parameters
    end

    class FacetProxy
      def initialize(facet_name, params)
        @params = params
        @facet_name = facet_name
      end

      def match_param(match_operator)
        return :"f.#{@facet_name}.facet.contains" if match_operator == 'CONTAINS'
        return :"f.#{@facet_name}.facet.prefix" if match_operator == 'STARTS_WITH'
      end

      def filter(value_or_values, match_operator = 'CONTAINS')
        match_field = match_param(match_operator)
        raise(ArgumentError, "Invalid match operator: #{match_operator}") unless match_field
        Array.wrap(value_or_values).compact.each { |value| @params.raw_parameter(match_field, value) }
        self
      end

      def with_statistics!
        @params.raw_parameter(:stats, 'on')
        @params.raw_parameter(:"stats.field", "{!countDistinct=true}#{@facet_name}")
        self
      end

      def rows(num)
        @params.raw_parameter(:"f.#{@facet_name}.facet.limit", num)
        self
      end

      def start(num)
        @params.raw_parameter(:"f.#{@facet_name}.facet.offset", num)
        self
      end

      # TODO: Enable direction after Solr 8 upgrade
      def sort(field, _direction)
        @params.raw_parameter(:"f.#{@facet_name}.facet.sort", field)
        self
      end
    end
  end
end
