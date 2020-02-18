# frozen_string_literal: true

module Types
  module Extensions
    class MapToDigitalObjects < GraphQL::Schema::FieldExtension
      def resolve(object:, arguments:, context:)
        yield(object, arguments)
      end

      def after_resolve(object:, value:, arguments:, context:, memo:)
        raise GraphQL::ExecutionError, 'ToDigitalObjects can only be downstream of SolrSearch' unless value.is_a?(OpenStruct) && value[:page_info].is_a?(OpenStruct)
        value[:nodes] = value[:nodes].map { |solr_doc| ::DigitalObject::Base.find(solr_doc['id']) }
        value
      end
    end
  end
end
