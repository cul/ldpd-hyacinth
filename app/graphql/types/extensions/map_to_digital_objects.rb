# frozen_string_literal: true

module Types
  module Extensions
    class MapToDigitalObjects < GraphQL::Schema::FieldExtension
      def resolve(object:, arguments:, context:)
        yield(object, arguments)
      end

      def after_resolve(object:, value:, arguments:, context:, memo:)
        raise GraphQL::ExecutionError, 'MapToDigitalObjects can only be downstream of SolrSearch' unless value.is_a?(OpenStruct) && value[:page_info].is_a?(OpenStruct)
        value[:nodes] = value[:nodes].map do |solr_doc|
          OpenStruct.new(
            id: solr_doc['id'],
            title: solr_doc['title_ssi'],
            projects: solr_doc['projects_ssim'],
            digital_object_type: solr_doc['digital_object_type_ssi'],
            number_of_children: solr_doc['number_of_children_isi'],
            parent_ids: solr_doc['parent_ids_ssim']
          )
        end
        value
      end
    end
  end
end
