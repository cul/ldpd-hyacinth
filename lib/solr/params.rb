# frozen_string_literal: true

module Solr
  class Params
    attr_reader :parameters

    VALID_BOOLEAN_OPERATORS = { and: ' AND ', or: ' OR ' }.freeze
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

    def fq(field, value_or_values, match_operator = 'EQUALS', boolean_operator = :or)
      raise(ArgumentError, "Invalid match operator: #{match_operator}") unless VALID_FILTER_MATCHES.include?(match_operator)
      raise(ArgumentError, "Invalid boolean operator: #{boolean_operator}") unless VALID_BOOLEAN_OPERATORS.include?(boolean_operator)
      escaped_values = Array.wrap(value_or_values).map { |value| Solr::Utils.escape(value).gsub(' ', '\ ') }
      filter_data = VALID_FILTER_MATCHES[match_operator]
      value = filter_data[:value] || escaped_values.map { |ev| filter_data[:value_template]&.%(ev) || ev }.join(VALID_BOOLEAN_OPERATORS[boolean_operator])
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
    end

    def sort(field, direction)
      raise ArgumentError, "direction must be one of #{VALID_SORT_DIRECTION.join(', ')}, instead got '#{direction}'" unless VALID_SORT_DIRECTION.include?(direction)

      @parameters[:sort] = "#{field} #{direction}"
    end

    def to_h
      parameters[:"facet.field"].present? ? parameters.merge(facet: 'on') : parameters
    end

    class FacetProxy
      def initialize(facet_name, params)
        @params = params
        @facet_name = facet_name
      end

      def with_statistics!
        @params.raw_parameter(:stats, 'on')
        @params.raw_parameter(:"stats.field", "{!countDistinct=true}#{@facet_name}")
      end

      def rows(num)
        @params.raw_parameter(:"f.#{@facet_name}.facet.limit", num)
      end

      def start(num)
        @params.raw_parameter(:"f.#{@facet_name}.facet.offset", num)
      end

      # TODO: Enable direction after Solr 8 upgrade
      def sort(field, _direction)
        @params.raw_parameter(:"f.#{@facet_name}.facet.sort", field)
      end
    end
  end
end
