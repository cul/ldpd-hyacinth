class Hyacinth::Utils::CsvImportExportUtils
  PATH_INVALID = 'Invalid path.  Attempted to access string key at array index.'
  PATH_MISSING = 'Path not found.  To create path, pass a value true to the create_missing_path method parameter.'

  ##############################
  # CSV to Digital Object Data #
  ##############################

  def self.csv_to_digital_object_data(csv_data_string)
    line_counter = -1
    header = Hyacinth::Csv::Header.new

    CSV.parse(csv_data_string) do |row|
      line_counter += 1

      # first line is human readable, so we ignore it
      next if line_counter == 0

      # second line is the real header line, so store it as such
      if line_counter == 1
        header.fields = row.map { |header_data| header_to_input_field(header_data) }
        next
      end

      # process the rest of the lines ...
      yield header.document_for(row)
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
    digital_object_data[Hyacinth::Csv::Fields::Dynamic::DATA_KEY] ||= {}
    input_field = Hyacinth::Csv::Fields::Dynamic.new(input_field) unless input_field.is_a? Hyacinth::Csv::Fields::Dynamic

    put_object_at_builder_path(digital_object_data, input_field, value, true)
  end

  ##############################
  # Digital Object Data to CSV #
  ##############################

  def self.digital_object_data_to_csv(_digital_object_data)
    ''
  end
end
