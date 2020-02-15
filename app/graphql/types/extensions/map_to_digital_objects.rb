# frozen_string_literal: true

module Types
  module Extensions
    class MapToDigitalObjects < GraphQL::Schema::FieldExtension
      def resolve(object:, arguments:, context:)
        yield(object, arguments)
      end

      def after_resolve(object:, value:, arguments:, context:, memo:)
        raise GraphQL::ExecutionError, 'ToDigitalObjects can only be downstream of Paginate' unless value.is_a?(OpenStruct) && value[:page_info].is_a?(OpenStruct)
        value[:nodes] = value[:nodes].map { |digital_object_record| ::DigitalObject::Base.find(digital_object_record.uid) }
        value
      end
    end
  end
end
