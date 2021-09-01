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
          merge_title_fields_for!(digital_object, solr_document)
          merge_descriptive_fields_for!(digital_object, solr_document)
          merge_rights_fields_for!(digital_object, solr_document)
          merge_term_uris_for!(digital_object, solr_document)
          solr_document.compact
        end

        def merge_core_fields_for(digital_object, solr_document = {})
          merge_core_fields_for!(digital_object, solr_document.dup)
        end

        def merge_core_fields_for!(digital_object, solr_document = {})
          identifiers = digital_object.identifiers.to_a
          solr_document.merge!(
            'id' => digital_object.uid,
            'state_ssi' => digital_object.state,
            'digital_object_type_ssi' => digital_object.digital_object_type,
            'doi_ssi' => digital_object.doi,
            'identifier_ssim' => identifiers,
            'primary_project_ssi' => digital_object.primary_project&.string_key,
            'projects_ssim' => project_keys_for(digital_object),
            'created_at_dtsi' => iso8601_or_nil(digital_object.created_at),
            'updated_at_dtsi' => iso8601_or_nil(digital_object.updated_at),
            'number_of_children_isi' => digital_object.number_of_children,
            'parent_ids_ssim' => digital_object.parents.map(&:uid)
          )
          add_identifiers(
            identifiers + [digital_object.uid] + digital_object.preservation_target_uris.map { |uri| uri.split('//').last },
            solr_document
          )
        end

        def merge_title_fields_for(digital_object, solr_document = {})
          merge_title_fields_for!(digital_object, solr_document.dup)
        end

        def merge_title_fields_for!(digital_object, solr_document = {})
          display_label = digital_object.generate_display_label
          # top-level attributes keyed as properties
          solr_document['display_label_ss'] = display_label
          solr_document['sort_title_ssi'] ||= display_label
          if digital_object.title.present?
            solr_document['sort_title_ssi'] = digital_object.title.dig('value', 'sort_portion')
            # title attributes keyed as string key paths
            key = Hyacinth::DigitalObject::SolrKeys
            key.for_string_key_path(['title', 'sort_portion'], 'ssi')
            solr_document[key.for_string_key_path(['title', 'sort_portion'], 'ssi')] = digital_object.title.dig('value', 'sort_portion')
            solr_document[key.for_string_key_path(['title', 'non_sort_portion'], 'ssi')] = digital_object.title.dig('value', 'non_sort_portion')
            solr_document[key.for_string_key_path(['title', 'subtitle'], 'ssi')] = digital_object.title['subtitle']
            solr_document[key.for_string_key_path(['title', 'lang'])] = digital_object.title.dig('value_lang', 'tag')
          end
          add_keywords(display_label, solr_document)
          add_titles(display_label, solr_document)
        end

        def merge_descriptive_fields_for(digital_object, solr_document = {})
          merge_descriptive_fields_for!(digital_object, solr_document.dup)
        end

        def merge_descriptive_fields_for!(digital_object, solr_document = {})
          merge_dynamic_fields(digital_object.descriptive_metadata, 'descriptive', solr_document)
        end

        def merge_rights_fields_for(digital_object, solr_document = {})
          merge_rights_fields_for!(digital_object, solr_document.dup)
        end

        def merge_rights_fields_for!(digital_object, solr_document = {})
          return unless digital_object.can_have_rights?

          # Add flag for rights content at all
          solr_document['rights_category_present_bi'] = digital_object.rights.present?

          merge_dynamic_fields(digital_object.rights, "#{digital_object.digital_object_type}_rights", solr_document)
        end

        def merge_term_uris_for!(digital_object, solr_document = {})
          term_uris = {}
          digital_object.metadata_attributes.map do |metadata_attribute_name, type_def|
            next unless type_def.is_a? Hyacinth::DigitalObject::TypeDef::DynamicFieldData
            type_def.term_uris(digital_object.send(metadata_attribute_name), term_uris)
          end
          term_uris.each do |vocab, uris_list|
            solr_key = Hyacinth::DigitalObject::SolrKeys.for_string_key_path([vocab, 'term', 'uris'])
            solr_document[solr_key] = uris_list.to_a.compact
          end
        end

        def search_types
          SEARCH_TYPES.keys
        end

        def search_field(search_type)
          SEARCH_TYPES[search_type]
        end

        private

          def iso8601_or_nil(datetime)
            datetime&.utc&.iso8601
          end

          def merge_dynamic_fields(dynamic_field_data, metadata_form, solr_document)
            Hyacinth::DynamicFieldsMap.new(metadata_form).all_fields.each do |config| # For each dynamic field
              path = config[:path]
              values = extract_dynamic_field_values_at(dynamic_field_data, path)
              values.reject!(&:blank?) # we don't want to index blank values (e.g. '' or false)

              # We index data about the presence or absence of ALL dynamic fields
              if values.present?
                solr_document[Hyacinth::DigitalObject::SolrKeys.for_dynamic_field(path, 'present_bi')] = true

                # We only index actual values for non-textarea fields
                solr_document[Hyacinth::DigitalObject::SolrKeys.for_dynamic_field(path)] = values unless config[:field_type] == DynamicField::Type::TEXTAREA
              end

              # Adding to appropriate search type
              add_keywords(values, solr_document) if config[:is_keyword_searchable]
              add_titles(values, solr_document) if config[:is_title_searchable]
              add_identifiers(values, solr_document) if config[:is_identifier_searchable]
            end
            solr_document
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
            (digital_object.other_projects.map(&:string_key) + [digital_object.primary_project&.string_key]).compact
          end

          # Methods to add values for keyword, title and identifier search.
          # Available methods are add_keywords, add_titles and add_identifiers
          SEARCH_TYPES.each do |search_type, solr_key|
            define_method "add_#{search_type.pluralize}" do |value, solr_document|
              values = Array.wrap(value)
              (solr_document[solr_key] ||= []).concat(values).uniq!
              solr_document
            end
          end
      end
    end
  end
end
