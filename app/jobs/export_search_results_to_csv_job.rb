class ExportSearchResultsToCsvJob < ActiveJob::Base
  include Hyacinth::Csv::Flatten

  SUPPRESSED_ON_EXPORT = [
    '_uuid', '_dc_type', '_state', '_title', '_created', '_modified', '_created_by', '_modified_by',
    '_digital_object_data_location_uri',
    '_project.uri', '_project.short_label'
  ]
  INTERNAL_FIELD_REGEXES_ALLOWED_ON_IMPORT = [
    '_pid', '_doi', '_merge_dynamic_fields', '_publish', '_first_published', '_digital_object_type.string_key',
    '_restrictions.restricted_size_image', '_restrictions.restricted_onsite',
    '_perform_derivative_processing', '_mint_reserved_doi',
    /^_publish_target_data\.(string_key|publish_url|api_key|representative_image_pid|short_title|short_description|full_description|restricted|slug|site_url)$/,
    /^_parent_digital_objects-\d+\.(identifier|pid)$/, /^_identifiers-\d+$/, /^_project\.(string_key|pid)$/,
    /^_publish_targets-\d+\.(string_key|pid)$/, /^_parent_digital_objects-\d+\.(identifier|pid)$/,
    *DigitalObject::Asset::MAIN_RESOURCE_NAME.yield_self { |resource_type_name| ["_import_file.#{resource_type_name}.import_type", "_import_file.#{resource_type_name}.import_location", "_import_file.#{resource_type_name}.original_file_path"] },
    *DigitalObject::Asset::SERVICE_RESOURCE_NAME.yield_self { |resource_type_name| ["_import_file.#{resource_type_name}.import_type", "_import_file.#{resource_type_name}.import_location"] },
    *DigitalObject::Asset::ACCESS_RESOURCE_NAME.yield_self { |resource_type_name| "_import_file.#{resource_type_name}.import_location" },
    *DigitalObject::Asset::POSTER_RESOURCE_NAME.yield_self { |resource_type_name| "_import_file.#{resource_type_name}.import_location" }
  ]
  CONTROLLED_TERM_CORE_SUBFIELDS_ALLOWED_ON_IMPORT = ['uri', 'value', 'authority', 'type']

  queue_as Hyacinth::Queue::DIGITAL_OBJECT_CSV_EXPORT

  def perform(csv_export_id)
    start_time = Time.now

    csv_export = CsvExport.find(csv_export_id)
    user = csv_export.user
    search_params = JSON.parse(csv_export.search_params)
    path_to_csv_file = File.join(HYACINTH[:csv_export_directory], "export-#{csv_export.id}-#{Time.now.strftime('%Y%m%d_%H%M%S')}.csv")

    temp_field_indexes = {}

    # Create temporary CSV file that contains data, but no headers.
    # Headers will be gathered in memory, and then sorted later on.
    # Then the final CSV will be generated from the in-memory headers
    # and the temporary CSV file.
    number_of_records_processed = 0
    CSV.open(path_to_csv_file + '.tmp', 'wb') do |csv|
      map_temp_field_indexes(search_params, user, temp_field_indexes) do |column_map, digital_object_data|
        headers = column_map.each_with_object([]) do |entry, memo|
          memo[entry[1]] = Hyacinth::Csv::Fields::Base.from_header(entry[0])
        end
        # Write entire row to CSV file
        row = Hyacinth::Csv::Row.from_document(digital_object_data, headers)
        csv << row.fields
        number_of_records_processed += 1
        csv_export.update(number_of_records_processed: number_of_records_processed) if number_of_records_processed % 1000 == 0
      end
    end

    sorted_column_names = temp_field_indexes.keys.sort(&ExportSearchResultsToCsvJob.method(:sort_pointers))
    write_csv(path_to_csv_file, sorted_column_names, temp_field_indexes)

    # Delete temporary CSV
    FileUtils.rm(path_to_csv_file + '.tmp')
    csv_export.path_to_csv_file = path_to_csv_file

    csv_export.duration = (Time.now - start_time)
    csv_export.number_of_records_processed = number_of_records_processed
    csv_export.success!
    csv_export.save
  end

  def map_temp_field_indexes(search_params, user, map = {})
    # Common fields to all objects
    map['_pid'] ||= map.length
    map['_project.string_key'] ||= map.length
    map['_digital_object_type.string_key'] ||= map.length
    DigitalObject::Base.search_in_batches(search_params, user, 50) do |digital_object_data|
      ### Handle core fields

      # identifiers, except for the pid or uuid which are shown in their own columns (note: uuid isn't currently shown in CSV, but will be at some point)
      digital_object_data.fetch('identifiers', []).reject! do |identifier|
        identifier == digital_object_data['pid'] || identifier == digital_object_data['uuid']
      end
      digital_object_data.fetch('identifiers', []).size.times do |index|
        map["_identifiers-#{index + 1}"] ||= map.length
      end

      # parent_digital_objects
      digital_object_data.fetch('parent_digital_objects', []).size.times do |index|
        map["_parent_digital_objects-#{index + 1}.pid"] ||= map.length
      end

      # publish_targets
      digital_object_data.fetch('publish_targets', []).size.times do |index|
        map["_publish_targets-#{index + 1}.string_key"] ||= map.length
      end

      ### Handle dynamic fields
      # For controlled fields, skip the 'vocabulary_string_key', 'type' and
      # 'internal_id' fields because they're not helpful
      flat_keys = keys_for_document(digital_object_data, true).reject do |csv_header|
        reject_field = false
        ['.vocabulary_string_key', '.type', '.internal_id', '.pid', '.display_label'].each do |ending|
          reject_field = true if csv_header.ends_with?(ending)
        end
        reject_field
      end
      flat_keys -= SUPPRESSED_ON_EXPORT
      flat_keys.each do |csv_header|
        map[csv_header] ||= map.length
      end

      yield map, digital_object_data if block_given?
    end
    map
  end

  def write_csv(path_to_csv_file, field_list, field_index_map)
    # Open new CSV for writing
    CSV.open(path_to_csv_file, 'wb') do |final_csv|
      # Write out human-friendly column display labels
      final_csv << Hyacinth::Utils::CsvFriendlyHeaders.hyacinth_headers_to_friendly_headers(field_list)

      # Write out column headers
      final_csv << field_list

      # Open temporary CSV for reading
      CSV.open(path_to_csv_file + '.tmp', 'rb') do |temp_csv|
        # Copy and reorder row data from temp csv to final csv

        temp_csv.each do |temp_csv_row|
          reordered_temp_csv_row = []
          field_list.each do |field|
            row_index = field_index_map[field]
            reordered_temp_csv_row << temp_csv_row[row_index]
          end

          final_csv << reordered_temp_csv_row
        end
      end
    end
  end

  def self.sort_pointers(a, b)
    Hyacinth::Csv::Fields::Base.from_header(a) <=> Hyacinth::Csv::Fields::Base.from_header(b)
  end
end
