class Hyacinth::Utils::CsvImportExportUtils
  PATH_INVALID = 'Invalid path.  Attempted to access string key at array index.'
  PATH_MISSING = 'Path not found.  To create path, pass a value true to the create_missing_path method parameter.'

  ##############################
  # CSV to Digital Object Data #
  ##############################

  def self.csv_to_digital_object_data(csv_data_string)
    ## Check whether this csv file contains non-ASCII character. If it does, it needs to be UTF-8 for us to handle those characters properly.
    # found_non_ascii_characters = contents.index(Regexp.new('[^\x00-\x7F]')).is_a?(Fixnum)

    # Convert CSV data to UTF-8 if it isn't already UTF-8
    detection = CharlockHolmes::EncodingDetector.detect(csv_data_string)
    if detection[:ruby_encoding] != Encoding::UTF_8.to_s || detection[:confidence] != 100
      csv_data_string = CharlockHolmes::Converter.convert csv_data_string, detection[:encoding], Encoding::UTF_8.to_s # Convert to UTF-8
    else
      csv_data_string = csv_data_string.force_encoding(Encoding::UTF_8) # Force UTF-8 all the time because that's what Hyacinth uses internally
    end

    header = Hyacinth::Csv::Header.new

    csv_row_number = -1

    CSV.parse(csv_data_string) do |row|
      csv_row_number += 1

      # first line is human readable, so we ignore it
      next if csv_row_number == 0

      # second line is the real header line, so store it as such
      if csv_row_number == 1
        header.fields = row.map { |header_data| header_to_input_field(header_data) }
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

  def self.create_import_job_from_csv_data(csv_data_string, import_filename, user)
    import_job = ImportJob.new(name: import_filename, user: user)

    # First, run through the CSV and do a quick validation
    begin
      Hyacinth::Utils::CsvImportExportUtils.csv_to_digital_object_data(csv_data_string) do |digital_object_data, csv_row_number|
        # Do some quick CSV data checks to find easy mistakes and avoid queueing jobs that we know will fail

        # 1) Check for project
        import_job.errors.add(:invalid_csv, "Missing project for row: #{csv_row_number + 1}") if digital_object_data['project'].blank?
      end
    rescue CSV::MalformedCSVError
      # Handle invalid CSV
      import_job.errors.add(:invalid_csv, 'Invalid CSV File')
    end

    # Assuming there were no validation errors, run through the CSV data again and do an import for real
    unless import_job.errors.any?
      import_job.save

      Hyacinth::Utils::CsvImportExportUtils.csv_to_digital_object_data(csv_data_string) do |digital_object_data, csv_row_number|
        digital_object_import = DigitalObjectImport.create!(
          import_job: import_job,
          digital_object_data: JSON.generate(digital_object_data),
          csv_row_number: csv_row_number + 1
        )

        # Queue up digital_object_import for procssing
        Hyacinth::Queue.process_digital_object_import(digital_object_import.id)
      end
    end

    import_job
  end
end
