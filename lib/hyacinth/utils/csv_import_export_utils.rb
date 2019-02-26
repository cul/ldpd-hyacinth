class Hyacinth::Utils::CsvImportExportUtils
  PATH_INVALID = 'Invalid path.  Attempted to access string key at array index.'
  PATH_MISSING = 'Path not found.  To create path, pass a value true to the create_missing_path method parameter.'
  NOT_IN_SPREADSHEET_PREFIX = 'not-in-spreadsheet:'

  ##############################
  # CSV to Digital Object Data #
  ##############################

  def self.csv_to_digital_object_data(csv_data_string)
    ## Check whether this csv file contains non-ASCII character. If it does, it needs to be UTF-8 for us to handle those characters properly.
    # found_non_ascii_characters = contents.index(Regexp.new('[^\x00-\x7F]')).is_a?(Integer)

    # Convert CSV data to UTF-8 if it isn't already UTF-8
    detection = CharlockHolmes::EncodingDetector.detect(csv_data_string)
    if detection[:ruby_encoding] != Encoding::UTF_8.to_s || detection[:confidence] != 100
      csv_data_string = CharlockHolmes::Converter.convert csv_data_string, detection[:encoding], Encoding::UTF_8.to_s # Convert to UTF-8
    else
      csv_data_string = csv_data_string.force_encoding(Encoding::UTF_8) # Force UTF-8 all the time because that's what Hyacinth uses internally
    end

    header = Hyacinth::Csv::Header.new

    csv_row_number = -1

    found_header_row = false
    CSV.parse(csv_data_string) do |row|
      # Strip all leading and trailing whitespace from each cell
      row = row.map { |cell_value| cell_value.is_a?(String) ? cell_value.strip : cell_value }

      csv_row_number += 1

      unless found_header_row
        if row[0].start_with?('_')
          # found header row
          header.fields = row.map { |header_data| header_to_input_field(header_data) }
          found_header_row = true
        end
        next
      end

      # process the rest of the lines ...
      yield header.document_for(row), csv_row_number
    end
  end

  def self.header_to_input_field(header_data)
    Hyacinth::Csv::Header.header_to_input_field(header_data)
  end

  # Process a single CSV data row and return digital_object_data
  def self.process_csv_row(headers, row_data)
    Hyacinth::Csv::Header.new(headers).document_for(row_data)
  end

  def self.process_internal_field_value(digital_object_data, value, input_field)
    input_field = Hyacinth::Csv::Fields::Internal.new(input_field) unless input_field.is_a? Hyacinth::Csv::Fields::Internal

    # If this value is an array, remove any blank strings or hashes with only blank values
    if value.is_a?(Array) && value.length > 0
      if value[0].is_a?(String)
        value.reject!(&:blank?) # Remove blank String elements
      elsif value[0].is_a?(Hash)
        value.reject! { |_key, val| val.blank? } # Remove hash elements with blank values
      end
    end

    put_object_at_builder_path(digital_object_data, input_field, value, true)
  end

  def self.get_object_at_builder_path(obj, input_field)
    input_field = Hyacinth::Csv::Fields::Base.new(input_field) if input_field.is_a? Array
    input_field.get_value(obj)
  end

  def self.put_object_at_builder_path(object_to_modify, input_field, object_to_put, create_missing_path = true)
    input_field = Hyacinth::Csv::Fields::Base.new(input_field) if input_field.is_a? Array
    input_field.put_value(object_to_modify, object_to_put, create_missing_path)
  end

  def self.process_dynamic_field_value(digital_object_data, value, input_field, _current_builder_path)
    # Note: All dynamic field data goes under a top level key called 'dynamic_field_data'
    digital_object_data[DigitalObject::DynamicField::DATA_KEY] ||= {}
    input_field = Hyacinth::Csv::Fields::Dynamic.new(input_field) unless input_field.is_a? Hyacinth::Csv::Fields::Dynamic

    put_object_at_builder_path(digital_object_data, input_field, value, true)
  end

  def self.validate_import_job_csv_data(csv_data_string, user, import_job)
    # Validate csv headers to make sure that all fields exist
    validate_csv_headers(csv_data_string, import_job)

    project_search_criteria_referenced_in_spreadsheet = []

    begin
      Hyacinth::Utils::CsvImportExportUtils.csv_to_digital_object_data(csv_data_string) do |digital_object_data, csv_row_number|
        # Do some quick CSV data checks to find easy mistakes and avoid queueing jobs that we know will fail

        # Project is required for new DigitalObjects
        import_job.errors.add(:invalid_csv, "Missing project for row: #{csv_row_number + 1}") if digital_object_data['project'].blank? && digital_object_data['pid'].blank?

        # Make sure that referenced files actually exist
        validate_import_file_import_path_if_present(digital_object_data, csv_row_number, import_job)

        # Collect list of projects present in spreadsheet so that we can ensure that the given user is allowed to create/update data in those projects
        project_search_criteria_referenced_in_spreadsheet << digital_object_data['project']
      end
    rescue CSV::MalformedCSVError
      # Handle invalid CSV
      import_job.errors.add(:invalid_csv, 'Invalid CSV File')
    rescue Hyacinth::Exceptions::InvalidCsvHeader => e
      import_job.errors.add(:invalid_csv_header, e.message)
    end

    project_search_criteria_referenced_in_spreadsheet.uniq!

    validate_project_permission_for_project_string_keys(user, project_search_criteria_referenced_in_spreadsheet, import_job)
  end

  def self.validate_import_file_import_path_if_present(digital_object_data, csv_row_number, import_job)
    if digital_object_data['import_file'].present? && digital_object_data['import_file']['import_path'].present?

      import_file_type = digital_object_data['import_file']['import_type']
      import_file_path = digital_object_data['import_file']['import_path']

      # Concatenate upload directory path with import_file_path if this file comes from the upload directory
      if import_file_type == DigitalObject::Asset::IMPORT_TYPE_UPLOAD_DIRECTORY
        import_file_path = File.join(HYACINTH['upload_directory'], import_file_path)
      end

      # Check to see if a file exists at import_file_path
      unless File.file?(import_file_path)
        import_job.errors.add(:file_not_found, "For CSV row #{csv_row_number}, could not find file at _import_file.import_path => " + import_file_path)
      end
    end
  end

  def self.validate_project_permission_for_project_string_keys(user, project_search_criteria_referenced_in_spreadsheet, import_job)
    project_search_criteria_referenced_in_spreadsheet.each do |project_search_criteria|
      project = Project.find_by(project_search_criteria)
      if project.nil?
        import_job.errors.add(:project, 'not found with search criteria: ' + project_search_criteria.inspect)
      elsif user.present? && (!user.permitted_in_project?(project, :create) || !user.permitted_in_project?(project, :update))
        # User must have create and update permissions for a project in order to do CSV imports
        import_job.errors.add(:project_permission_denied, 'for import into project with string key: ' + project.string_key)
      end
    end
  end

  def self.create_import_job_from_csv_data(csv_data_string, import_filename, user, priority = :low)
    import_job = ImportJob.new(name: import_filename, user: user, priority: priority)

    # First, run through the CSV and do some quick validations
    validate_import_job_csv_data(csv_data_string, user, import_job)

    # Assuming there were no validation errors, run through the CSV data again and do an import for real
    unless import_job.errors.any?
      import_job.save # Save the import job so that we generate a unique ID for the job

      # Use the import job ID to generate the file path to the saved csv file
      path_to_csv_file = File.join(HYACINTH['processed_csv_import_directory'], "import-#{import_job.id}-#{Time.now.strftime('%Y%m%d_%H%M%S')}.csv")
      import_job.path_to_csv_file = path_to_csv_file
      import_job.save # Save the import_job again so that the path_to_csv_file is persisted to the database

      # Save the csv file to the filesystem
      IO.binwrite(path_to_csv_file, csv_data_string)

      prerequisite_row_map = Hyacinth::Utils::CsvImportExportUtils.prerequisite_row_map_for_csv_data(csv_data_string)

      Hyacinth::Utils::CsvImportExportUtils.csv_to_digital_object_data(csv_data_string) do |digital_object_data, csv_row_number|
        prerequisite_csv_row_numbers = prerequisite_row_map[csv_row_number].present? ? prerequisite_row_map[csv_row_number].map { |row_number| row_number + 1 } : [] # CSV row numbers are 1-indexed

        digital_object_import = DigitalObjectImport.create!(
          import_job: import_job,
          digital_object_data: JSON.generate(digital_object_data),
          csv_row_number: csv_row_number + 1, # CSV row numbers are 1-indexed
          prerequisite_csv_row_numbers: prerequisite_csv_row_numbers
        )

        # Queue up digital_object_import for procssing
        Hyacinth::Queue.process_digital_object_import(digital_object_import)
      end
    end
    import_job
  end

  # Takes a csv data string and returns a map that, for each row, lists
  # prerequisite rows
  def self.prerequisite_row_map_for_csv_data(csv_data_string)
    index_of_parent_headers = []
    index_of_pid_header = nil

    row_number_for_header_row = 0

    # Get index of parent headers if present
    CSV.parse(csv_data_string) do |row|
      unless row[0].start_with?('_')
        # Go to second row if first row doesn't contain headers
        row_number_for_header_row += 1
        next
      end
      row.each_with_index do |header, index|
        index_of_parent_headers << index if header =~ /^_parent_digital_objects-\d+\.(identifier|pid)$/
        index_of_pid_header = index if header == '_pid'
      end
      break
    end

    return {} if index_of_parent_headers.blank?

    identifiers_to_row_numbers = identifiers_to_row_numbers_for_csv_data(csv_data_string)

    prerequisite_rows_based_on_headers(csv_data_string, row_number_for_header_row, index_of_parent_headers, identifiers_to_row_numbers)
  end

  def self.parent_row_number_or_placeholder_value(parent_identifier, identifiers_to_row_numbers)
    value = identifiers_to_row_numbers[parent_identifier]
    # If parent_identifier was present, but parent_row_number is nil, that
    # means that this row references a parent that's not in the spreadsheet,
    # so we'll need to use a placeholder value for the parent row, just
    # for the purposes of seeing the dependency chain.
    value = NOT_IN_SPREADSHEET_PREFIX + parent_identifier if value.nil?
    value
  end

  def self.prerequisite_rows_based_on_headers(csv_data_string, row_number_for_header_row, index_of_parent_headers, identifiers_to_row_numbers)
    prerequisite_row_map = {}

    if index_of_parent_headers.length > 0
      prerequisite_rows_to_dependent_rows = {}
      row_counter = -1
      CSV.parse(csv_data_string) do |row|
        row_counter += 1
        next if row_counter <= row_number_for_header_row

        ### Note: We can't guarantee that a row with a pid is in Hyacinth already.
        # It could be an indication that we want to import an object that's in Fedora,
        # but not Hyacinth.

        index_of_parent_headers.each do |index|
          parent_identifier = row[index]
          next unless parent_identifier.present?
          parent_row_number = parent_row_number_or_placeholder_value(parent_identifier, identifiers_to_row_numbers)

          prerequisite_row_map[row_counter] ||= []

          # If THIS row's prerequisite row has other rows that are dependent on it,
          # then THIS row's prerequisite should be the HIGHEST one of those rows.
          if prerequisite_rows_to_dependent_rows.key?(parent_row_number)
            max_value = prerequisite_rows_to_dependent_rows[parent_row_number].max
            prerequisite_row_map[row_counter] << max_value unless prerequisite_row_map[row_counter].include?(max_value)
          else
            # THIS row's prerequisite row has no other rows that are dependent on it,
            # so we'll make THIS row directly dependent on it.
            prerequisite_row_map[row_counter] << parent_row_number
          end

          # Keep track of the set of all rows that depend on this prerequisite parent row
          prerequisite_rows_to_dependent_rows[parent_row_number] ||= []
          prerequisite_rows_to_dependent_rows[parent_row_number] << row_counter
        end
      end
    end

    remove_not_in_spreadsheet_prefix_values_from_prerequisite_row_map(prerequisite_row_map)

    prerequisite_row_map
  end

  # Removes values from prerequisite_row_map that start with
  # NOT_IN_SPREADSHEET_PREFIX, since this was just a placeholder used to
  # seed the dependency chain. And then remove any key-value pairs that have
  # empty array values after the cleanup.
  def self.remove_not_in_spreadsheet_prefix_values_from_prerequisite_row_map(prerequisite_row_map)
    prerequisite_row_map.each { |key, val| val.delete_if { |element| element.is_a?(String) && element.starts_with?(NOT_IN_SPREADSHEET_PREFIX) } }
    prerequisite_row_map.delete_if { |key, val| val.blank? }
    prerequisite_row_map
  end

  def self.identifiers_to_row_numbers_for_csv_data(csv_data_string)
    identifiers_to_row_numbers = {}
    indexes_of_identifier_headers = []

    row_number_for_header_row = 0

    CSV.parse(csv_data_string) do |row|
      unless row[0].start_with?('_')
        # Go to second row if first row doesn't contain headers
        row_number_for_header_row += 1
        next
      end
      indexes_of_identifier_headers = indexes_of_identifier_headers_for_row(row)
      break
    end

    return {} if indexes_of_identifier_headers.blank?

    row_counter = -1
    CSV.parse(csv_data_string) do |row|
      row_counter += 1
      next if row_counter <= row_number_for_header_row
      indexes_of_identifier_headers.each do |index|
        val = row[index]
        identifiers_to_row_numbers[row[index]] = row_counter unless val.blank?
      end
    end

    identifiers_to_row_numbers
  end

  def self.indexes_of_identifier_headers_for_row(row)
    indexes_of_identifier_headers = []
    row.each_with_index do |header, index|
      indexes_of_identifier_headers << index if header =~ /^_identifiers-\d+$/ || header == '_pid'
    end
    indexes_of_identifier_headers
  end

  def self.validate_csv_headers(csv_data_string, import_job)
    # Generate list of all dynamic field path regular expressions
    # And validate against those field paths
    dynamic_field_regexes_allowed_on_import = all_dynamic_field_regexes

    index_of_first_new_line_char = csv_data_string.index("\n")
    if index_of_first_new_line_char.nil?
      import_job.errors.add(:invalid_csv, 'There appears to be a problem with the encoding of your CSV. No new line characters were detected.')
      return
    end
    index_of_second_new_line_char = csv_data_string.index("\n", index_of_first_new_line_char + 1)

    header_line_of_csv = get_header_line_of_csv(csv_data_string, index_of_first_new_line_char, index_of_second_new_line_char)

    # We're only using CSV.parse on the second row of data in the CSV file
    CSV.parse(header_line_of_csv) do |row|
      row.each do |header_string|
        next if header_string.nil? # Ignore blank headers
        next if valid_internal_field?(header_string)
        next if valid_dynamic_field?(header_string, dynamic_field_regexes_allowed_on_import)
        next if /^_asset_data\..+/.match(header_string) # Ignore _asset_data headers upon import. They often appear in CSV exports (with helpful read-only info about assets) and are ignored during import.
        import_job.errors.add(:invalid_csv_header, header_string)
      end
    end
  end

  def self.get_header_line_of_csv(csv_data_string, index_of_first_new_line_char, index_of_second_new_line_char)
    if csv_data_string.start_with?('_')
      # First line is header line
      csv_data_string[0...index_of_first_new_line_char]
    else
      # Second line is header line
      csv_data_string[(index_of_first_new_line_char + 1)...(index_of_second_new_line_char)]
    end
  end

  def self.all_dynamic_field_regexes
    dynamic_field_regexes = []
    string_keys_to_dynamic_fields = Hash[DynamicField.includes(:parent_dynamic_field_group).all.map { |dynamic_field| [dynamic_field.string_key, dynamic_field] }]
    string_keys_to_dynamic_field_groups = Hash[DynamicFieldGroup.includes(:parent_dynamic_field_group).all.map { |dynamic_field_group| [dynamic_field_group.string_key, dynamic_field_group] }]

    string_keys_to_dynamic_fields.each do |dynamic_field_string_key, dynamic_field|
      regex_to_build = dynamic_field_string_key

      # If this is a controlled term field, get all core and custom controlled term subfields
      if dynamic_field.dynamic_field_type == DynamicField::Type::CONTROLLED_TERM
        custom_term_fields_for_this_vocabulary = TERM_ADDITIONAL_FIELDS[dynamic_field.controlled_vocabulary_string_key].present? ? TERM_ADDITIONAL_FIELDS[dynamic_field.controlled_vocabulary_string_key].keys : []
        regex_to_build += '\\.(' + (ExportSearchResultsToCsvJob::CONTROLLED_TERM_CORE_SUBFIELDS_ALLOWED_ON_IMPORT + custom_term_fields_for_this_vocabulary).join('|') + ')'
      end

      next_df_or_dfg = dynamic_field
      while next_df_or_dfg.parent_dynamic_field_group.present?
        next_string_key = next_df_or_dfg.parent_dynamic_field_group.string_key
        next_df_or_dfg = string_keys_to_dynamic_field_groups[next_string_key]
        regex_to_build = next_string_key + '-\\d+:' + regex_to_build
      end

      regex_to_build = '^' + regex_to_build

      dynamic_field_regexes << Regexp.new(regex_to_build)
    end

    dynamic_field_regexes
  end

  def self.valid_internal_field?(header_string)
    ExportSearchResultsToCsvJob::INTERNAL_FIELD_REGEXES_ALLOWED_ON_IMPORT.each do |internal_field_regex|
      return true if internal_field_regex.match(header_string)
    end
    false
  end

  def self.valid_dynamic_field?(header_string, dynamic_field_regexes)
    dynamic_field_regexes.each do |dynamic_field_regex|
      return true if dynamic_field_regex.match(header_string)
    end
    false
  end
end
