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
    current_builder_path = [] # e.g. ['name', 0, 'name_role', 0]
    
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
    digital_object_data[ internal_field_header_name ] ||= []
    digital_object_data[ internal_field_header_name ] << value
  end
  
  def self.get_object_at_builder_path(obj, builder_path_arr)
    pointer = obj
    builder_path_arr.each do |element|
      # Element will be either a Fixnum (for array access) or a String (for hash access)
      if pointer[element]
        pointer = pointer[element]
      else
        return nil
      end
    end
    return pointer
  end
  
  def self.put_object_at_builder_path(object_to_modify, builder_path_arr, object_to_put, create_missing_path=true)
    
    obj_at_builder_path = self.get_object_at_builder_path(object_to_modify, builder_path_arr)
    raise 'Path not found.  To create path, pass a value true to the create_missing_path method parameter.' if obj_at_builder_path.nil? && (! create_missing_path)
    
    # ['name', 0, 'name_value', 'uri']
    # ['name', 0, 'name_value', 'value']
    
    if obj_at_builder_path.nil?
      pointer = object_to_modify
      
      builder_path_arr.each_with_index do |element, i|
        if i == (builder_path_arr.length-1)
          pointer[element] = object_to_put
          return
        end
        
        if pointer[element].nil?
          # We need to create this part of the path
          if builder_path_arr[i+i].is_a?(Fixnum)
            pointer[element] = []
          else
            pointer[element] = {}
          end
        end
        
        pointer = pointer[element]
      end
    else
      obj_at_builder_path = object_to_put
    end
    
    
  end
  
  def self.process_dynamic_field_value(digital_object_data, value, dynamic_field_header_name, current_builder_path)
    
    new_builder_path = dynamic_field_header_name.gsub(/-(\d+)/, ':\1').split(':').each{|piece| piece.match(/^\d+$/) ? piece.to_i : piece } # This line converts 'name-0:name_role-0:name_role_type' to ['name', 0, 'name_role', 0, 'name_role_type']
    new_dynamic_field_name = new_builder_path.pop # 'name_role_type'
    
    puts 'new_builder_path: ' + new_builder_path.inspect
    puts 'new_dynamic_field_name: ' + new_dynamic_field_name.inspect
    
    # At this point, new_builder_path is ['title', 0]
    # At this point, new_dynamic_field_name is 'title_non_sort_portion'
    
    self.put_object_at_builder_path(digital_object_data, new_builder_path + [new_dynamic_field_name], value, true)
  end

  ##############################
  # Digital Object Data to CSV #
  ##############################

  def self.digital_object_data_to_csv(digital_object_data)

    return ''

  end

end
