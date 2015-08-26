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
    
    # Current builder path is ['title']
    # New goal path is: ['name']
    # Need to determine difference
    #Difference is: ['name']
    
    #Found: name:name_value
    new_builder_path = internal_field_header_name.split(':') # e.g. ['name']
    new_dynamic_field_name = new_dynamic_field_group_path.pop # e.g. 'name_value'
    
    builder_path_difference = self.get_builder_path_difference(current_builder_path, new_builder_path) # returns ['name']
    
    
    #if digital_object_data[dynamic_field_group_path[0]].nil?
    #  digital_object_data[dynamic_field_group_path[0]] = []
    #end
    #
    #if digital_object_data[dynamic_field_group_path[0]][dynamic_field_group_path[1]].nil?
    #  digital_object_data[dynamic_field_group_path[0]] = []
    #end
    #
    #
    #
    #
    #digital_object_data[ internal_field_header_name ] ||= []
    #digital_object_data[ internal_field_header_name ] << value
  end
  
  
  def self.get_builder_path_difference(old_builder_path, new_builder_path)
    
  end

  ##############################
  # Digital Object Data to CSV #
  ##############################

  def self.digital_object_data_to_csv(digital_object_data)

    return ''

  end

end
