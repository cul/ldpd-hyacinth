# frozen_string_literal: true

module Hyacinth
  module Adapters
    module DigitalObjectSearchAdapter
      class Solr::DocumentGenerator
        def solr_document_for(digital_object)
          solr_document = merge_core_fields_for(digital_object)
          merge_dynamic_fields_for!(digital_object, solr_document)
          merge_rights_fields_for!(digital_object, solr_document)
          solr_document
        end

        def merge_core_fields_for(digital_object, solr_document = {})
          merge_core_fields_for!(digital_object, solr_document.dup)
        end

        def merge_core_fields_for!(digital_object, solr_document = {})
          indexable_title = digital_object.generate_title(true)
          solr_document.merge!(
            'id' => digital_object.uid,
            'state_ssi' => digital_object.state,
            'digital_object_type_ssi' => digital_object.digital_object_type,
            'doi_ssi' => digital_object.doi,
            'identifier_ssim' => digital_object.identifiers.to_a,
            'title_ssi' => indexable_title,
            'primary_project_ssi' => digital_object.primary_project&.string_key,
            'projects_ssim' => project_keys_for(digital_object)
          )
          add_keywords(indexable_title, solr_document)
          solr_document
        end

        def merge_dynamic_fields_for(digital_object, solr_document = {})
          merge_dynamic_fields_for!(digital_object, solr_document.dup)
        end

        def merge_dynamic_fields_for!(digital_object, solr_document = {})
          # TODO: iterate over dynamic fields for type and project
          # build keys, inspect values
          # add flag for content at all if field is not facetable
          collection_values = digital_object.descriptive_metadata.fetch('collection', [])
          collection_values.each do |collection_value|
            (solr_document['collection_ssim'] ||= []) << collection_value.dig('term', 'pref_label')
            add_keywords(collection_value.dig('term', 'pref_label'), solr_document)
          end
          solr_document
        end

        def merge_rights_fields_for(digital_object, solr_document = {})
          merge_rights_fields_for!(digital_object, solr_document.dup)
        end

        def merge_rights_fields_for!(digital_object, solr_document = {})
          # TODO: iterate over rights fields for type
          # build keys, inspect values
          # add flag for category content at all
          solr_document['copyright_status_copyright_statement_ssi'] =
            digital_object.rights.fetch('copyright_status', [])
                          .map { |rd| rd.dig('copyright_statement', 'pref_label') }
                          .first
          solr_document['copyright_status_copyright_statement_ssi'] ||= Hyacinth::DigitalObject::RightsFields::UNASSIGNED_STATUS_INDEX
          solr_document['rights_category_present_bi'] = digital_object.rights.present?
          solr_document.compact!
          solr_document
        end

        private

          def project_keys_for(digital_object)
            project_keys = digital_object.other_projects.map(&:string_key)
            project_keys << digital_object.primary_project.string_key if digital_object.primary_project
            project_keys
          end

          def add_keywords(value, solr_document)
            (solr_document['keywords_teim'] ||= []) << value
          end
      end
    end
  end
end
