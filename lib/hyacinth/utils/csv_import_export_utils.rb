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
      next if cell_value.blank?
      
      # Handle internal field, which is named with a leading underscore
      if column_indices_to_headers[index].start_with?('_')
        
        self.process_internal_field_value(digital_object_data, cell_value, column_indices_to_headers[index])
      else
        # Handle dynamic field
      end

    end
    
  end
  
  def self.process_internal_field_value(digital_object_data, value, internal_field_header_name)
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
