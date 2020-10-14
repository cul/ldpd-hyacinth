# frozen_string_literal: true

module Hyacinth
  module Adapters
    module DigitalObjectSearchAdapter
      class Solr::DocumentGenerator
        SEARCH_TYPES = {
          'keyword' => 'keyword_search_teim',
          'title' => 'title_search_teim',
          'identifier' => 'identifier_search_sim'
        }.freeze

        def solr_document_for(digital_object)
          solr_document = merge_core_fields_for(digital_object)
          merge_descriptive_fields_for!(digital_object, solr_document)
          merge_rights_fields_for!(digital_object, solr_document)
          solr_document
        end

        def merge_core_fields_for(digital_object, solr_document = {})
          merge_core_fields_for!(digital_object, solr_document.dup)
        end

        def merge_core_fields_for!(digital_object, solr_document = {})
          indexable_title = digital_object.generate_title
          solr_document.merge!(
            'id' => digital_object.uid,
            'state_ssi' => digital_object.state,
            'digital_object_type_ssi' => digital_object.digital_object_type,
            'doi_ssi' => digital_object.doi,
            'identifier_ssim' => digital_object.identifiers.to_a,
            'title_ss' => digital_object.generate_title,
            'sort_title_ssi' => digital_object.generate_title(true),
            'primary_project_ssi' => digital_object.primary_project&.string_key,
            'projects_ssim' => project_keys_for(digital_object),
            'created_at_dtsi' => digital_object.created_at.utc.iso8601,
            'updated_at_dtsi' => digital_object.updated_at.utc.iso8601,
            'number_of_children_isi' => digital_object.number_of_children,
            'parent_ids_ssim' => digital_object.parent_uids
          )
          add_keywords(indexable_title, solr_document)
          add_titles(indexable_title, solr_document)
          add_identifiers(digital_object.uid, solr_document)
          solr_document
        end

        def merge_descriptive_fields_for(digital_object, solr_document = {})
          merge_descriptive_fields_for!(digital_object, solr_document.dup)
        end

        def merge_descriptive_fields_for!(digital_object, solr_document = {})
          merge_dynamic_fields(digital_object.descriptive_metadata, 'descriptive', solr_document)
          solr_document
        end

        def merge_rights_fields_for(digital_object, solr_document = {})
          merge_rights_fields_for!(digital_object, solr_document.dup)
        end

        def merge_rights_fields_for!(digital_object, solr_document = {})
          return unless digital_object.can_have_rights?

          # Add flag for rights content at all
          solr_document['rights_category_present_bi'] = digital_object.rights.present?

          merge_dynamic_fields(digital_object.rights, "#{digital_object.digital_object_type}_rights", solr_document)

          solr_document.compact!
          solr_document
        end

        def search_types
          SEARCH_TYPES.keys
        end

        def search_field(search_type)
          SEARCH_TYPES[search_type]
        end

        private

          def merge_dynamic_fields(dynamic_field_data, metadata_form, solr_document)
            Hyacinth::DynamicFieldsMap.new(metadata_form).all_fields.each do |config| # For each dynamic field
              path = config[:path]

              values = extract_dynamic_field_values_at(dynamic_field_data, path)

              # Indexing field because its a non-textarea field
              if config[:field_type] != DynamicField::Type::TEXTAREA
                solr_key = Hyacinth::DigitalObject::SolrKeys.for_dynamic_field(path)
                solr_document[solr_key] = values
              end

              # Adding to appropriate search type
              add_keywords(values, solr_document) if config[:is_keyword_searchable]
              add_titles(values, solr_document) if config[:is_title_searchable]
              add_identifiers(values, solr_document) if config[:is_identifier_searchable]
            end
          end

          # Extracts all the values at the given path.
          #
          # @param [Array<Hash>|Hash] data
          # @param [Array<String>] path
          def extract_dynamic_field_values_at(data, path)
            return [] if data.blank?

            next_key = path[0]
            rest_of_path = path[1..]

            if next_key.blank?
              return data.map { |value| value.is_a?(Hash) ? value['pref_label'] : value }
            end

            if data.is_a?(Hash)
              extract_dynamic_field_values_at(data[next_key], rest_of_path)
            elsif data.is_a?(Array)
              extracted_values = data.flat_map { |d| d.fetch(next_key, nil) }.compact
              extract_dynamic_field_values_at(extracted_values, rest_of_path)
            end
          end

          def project_keys_for(digital_object)
            project_keys = digital_object.other_projects.map(&:string_key)
            project_keys << digital_object.primary_project.string_key if digital_object.primary_project
            project_keys
          end

          # Methods to add values for keyword, title and identifier search.
          # Available methods are add_keywords, add_titles and add_identifiers
          SEARCH_TYPES.each do |search_type, solr_key|
            define_method "add_#{search_type.pluralize}" do |value, solr_document|
              values = Array.wrap(value)
              (solr_document[solr_key] ||= []).concat(values)
            end
          end
      end
    end
  end
end
