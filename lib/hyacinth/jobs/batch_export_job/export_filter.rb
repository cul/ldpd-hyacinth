# frozen_string_literal: true

module Hyacinth
  module Jobs
    module BatchExportJob
      class ExportFilter
        DEFAULT_CORE_INCLUSION_FILTERS = [
          '_uid',
          '_asset_type',
          '_digital_object_type',
          '_doi',
          /_identifiers\[\d+\]/,
          /_parent_digital_objects\[\d+\]\..+/,
          '_primary_project.string_key',
          /_resources\..+/
        ].freeze

        DEFAULT_EXCLUSION_FILTERS = [
          '_created_at',
          /_created_by\..*/,
          /_digital_object_record\..*/,
          '_first_published_at',
          '_mint_doi',
          '_parent_uids',
          '_preservation_target_uris',
          '_preserve',
          '_serialization_version',
          '_state',
          /_structured_children\..*/,
          'updated_at',
          /_updated_by\..*/
        ].freeze

        attr_reader :inclusion_filters, :exclusion_filters

        # Initializer that allows for the setting of exclusion and inclusion filters. In order for
        # an export header to be included, it must match an inclusion filter AND not be rejected by
        # an exclusion filter.
        # @param [Array<String>] exclusion_filters An array of header filter strings or regular
        #                        expressions that will be used to filter a csv export file.
        #                        Example: ['_uid', /descriptive_metadata\..*/])
        # @param [Array<String>] inclusion_filters An array of header filter strings or regular
        #                        expressions that will be used to filter a csv export file.
        #                        Example: ['_uid', /descriptive_metadata\..*/])
        def initialize(inclusion_filters: [], exclusion_filters: [])
          @inclusion_filters = inclusion_filters
          @exclusion_filters = exclusion_filters
        end

        def self.default_export_filter
          self.new(
            inclusion_filters: self.default_inclusion_filters,
            exclusion_filters: self.default_exclusion_filters
          )
        end

        def self.default_inclusion_filters
          DEFAULT_CORE_INCLUSION_FILTERS + all_descriptive_metadata_field_filters
        end

        def self.default_exclusion_filters
          DEFAULT_EXCLUSION_FILTERS
        end

        def self.all_descriptive_metadata_field_filters
          descriptive_field_group_string_keys = DynamicFieldGroup.where(
            parent_type: 'DynamicFieldCategory',
            parent_id:  DynamicFieldCategory.where(metadata_form: :descriptive)
          ).pluck(:string_key)

          descriptive_field_group_string_keys.map { |string_key| /#{string_key}\[\d+\]\..+/ }
        end

        # Given an input batch export file, generates an output batch export file that only includes
        # headers that match the configured inclusion and exclusion filters.
        def generate_filtered_export(input_csv_file_path, output_csv_file_path)
          ordered_indexes_to_keep = nil
          CSV.open(output_csv_file_path, 'wb') do |output_csv|
            CSV.foreach(input_csv_file_path, 'rb') do |row|
              if ordered_indexes_to_keep.nil?
                ordered_indexes_to_keep = indexes_of_headers_to_keep(row)
                output_csv << row.values_at(*ordered_indexes_to_keep)
                next
              end

              output_csv << row.values_at(*ordered_indexes_to_keep)
            end
          end
        end

        def indexes_of_headers_to_keep(headers)
          headers.map.with_index { |header, index| header_matches_filters?(header) ? index : nil }.compact
        end

        def header_matches_filters?(header)
          inclusion_filters.find { |filter| header.match?(filter) }.present? &&
            exclusion_filters.find { |filter| header.match?(filter) }.blank?
        end
      end
    end
  end
end
