# frozen_string_literal: true

module Types
  module Extensions
    class MapToDigitalObjectSearchRecord < GraphQL::Schema::FieldExtension
      def resolve(object:, arguments:, context:)
        yield(object, arguments)
      end

      def after_resolve(object:, value:, arguments:, context:, memo:)
        raise GraphQL::ExecutionError, 'MapToDigitalObjectSearchRecord can only be downstream of SolrSearch' unless value.is_a?(OpenStruct) && value[:page_info].is_a?(OpenStruct)
        projects = Project.all.map { |p| [p.string_key, p] }.to_h
        value[:nodes] = value[:nodes].map do |solr_doc|
          OpenStruct.new(
            id: solr_doc['id'],
            title: solr_doc['title_ss'],
            projects: solr_doc.fetch('projects_ssim', []).map { |p| projects[p] },
            digital_object_type: solr_doc['digital_object_type_ssi'],
            number_of_children: solr_doc['number_of_children_isi'],
            parent_ids: solr_doc.fetch('parent_ids_ssim', [])
          )
        end
        value
      end
    end
  end
end
