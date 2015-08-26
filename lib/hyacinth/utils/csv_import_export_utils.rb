class Hyacinth::Utils::CsvImportExportUtils
  
  ##############################
  # CSV to Digital Object Data #
  ##############################

  def self.csv_to_digital_object_data(csv_data_string)
    line_counter = -1
    column_indices_to_headers = nil
    digital_object_data_results = []

    CSV.parse(csv_data_string) do |row|
      line_counter += 1

      # first line is human readable, so we ignore it
      if line_counter == 0
        next
      end

      # second line is the real header line, so store it as such
      if line_counter == 1 
        column_indices_to_headers = row
        next
      end

      # process the rest of the lines ...
      digital_object_data = self.process_csv_row(column_indices_to_headers, row)
      digital_object_data_results << digital_object_data unless digital_object_data.blank?
    end
    
    return digital_object_data_results
  end
  
  # Process a single CSV data row and return digital_object_data
  def self.process_csv_row(column_indices_to_headers, row_data)
    digital_object_data = {}
    current_builder_path = [] # e.g. ['name', 'name_role']
    
    row_data.each_with_index do |cell_value,index|
      if column_indices_to_headers[index].start_with?('_')
        # Handle internal field, which is named with a leading underscore
        self.process_internal_field_value(digital_object_data, cell_value, column_indices_to_headers[index])
      else
        # Handle dynamic field, which never starts with a leading underscore
        self.process_dynamic_field_value(digital_object_data, cell_value, column_indices_to_headers[index], current_builder_path)
      end
    end
    
  end
  
  def self.process_internal_field_value(digital_object_data, value, internal_field_header_name)
    return if value.blank?
    
    digital_object_data[ internal_field_header_name ] ||= []
    digital_object_data[ internal_field_header_name ] << value
  end
  
  def self.process_dynamic_field_value(digital_object_data, value, internal_field_header_name, current_builder_path)
    return if value.blank?
    
    #Found: title:title_non_sort_portion
    dynamic_field_group_path = internal_field_header_name.split(':') # e.g. title
    dynamic_field_name = dynamic_field_group_path.pop # e.g. title_non_sort_portion
    
    
    digital_object_data[ internal_field_header_name ] ||= []
    digital_object_data[ internal_field_header_name ] << value
  end

  ##############################
  # Digital Object Data to CSV #
  ##############################

  def self.digital_object_data_to_csv(digital_object_data)

    return ''

  end

end
