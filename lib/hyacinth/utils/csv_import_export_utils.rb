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
      next if line_counter == 0

      # second line is the real header line, so store it as such
      if line_counter == 1 
        column_indices_to_headers = row
        next
      end

      # process the rest of the lines ...
      digital_object_data = self.process_csv_row(column_indices_to_headers, row)
      
      yield digital_object_data
    end
  end
  
  # Process a single CSV data row and return digital_object_data
  def self.process_csv_row(column_indices_to_headers, row_data)
    digital_object_data = {}
    current_builder_path = [] # e.g. ['name', 0, 'name_role', 0]
    
    row_data.each_with_index do |cell_value,index|
      
      cell_value = '' if cell_value.nil? # If the cell value is nil, convert it into an empty string
      
      if column_indices_to_headers[index].start_with?('_')
        # Handle internal field, which is named with a leading underscore
        self.process_internal_field_value(digital_object_data, cell_value, column_indices_to_headers[index])
      else
        # Handle dynamic field, which never starts with a leading underscore
        self.process_dynamic_field_value(digital_object_data, cell_value, column_indices_to_headers[index], current_builder_path)
      end
    end
    
    return digital_object_data
  end
  
  def self.process_internal_field_value(digital_object_data, value, internal_field_header_name)
    
    raise "Internal field header names must begin with an underscore ('_')" if internal_field_header_name[0] != '_'
    
    # Converts '_publish_target-2.string_key' to ['_publish_target', 2, 'string_key']
    new_builder_path = internal_field_header_name.split(/[\.-]/).map{|piece|
      raise 'Internal field header names cannot be 0-indexed. Must be 1-indexed.' if piece == '0'
      piece.match(/^\d+$/) ? piece.to_i - 1 : piece # This line converts ['_publish_target', '2', 'string_key'] to ['_publish_target', 2, 'string_key']
    }
    
    # Remove underscore from first builder path element name
    new_builder_path[0] = new_builder_path[0][1..-1]
    
    self.put_object_at_builder_path(digital_object_data, new_builder_path, value, true)
    
  end
  
  def self.get_object_at_builder_path(obj, builder_path_arr)
    pointer = obj
    builder_path_arr.each do |element|
      
      # If pointer is an array and element is a string, this is an invalid path and we should raise an error.
      if pointer.is_a?(Array) && element.is_a?(String)
        raise Hyacinth::Exceptions::BuilderPathNotFoundError, "Invalid path.  Attempted to access string key at array index."
      end
      
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
    
    if obj_at_builder_path.nil? && (! create_missing_path)
      raise Hyacinth::Exceptions::BuilderPathNotFoundError, 'Path not found.  To create path, pass a value true to the create_missing_path method parameter.'
    end
    
    if obj_at_builder_path.nil?
      pointer = object_to_modify
      
      builder_path_arr.each_with_index do |element, i|
        if i == (builder_path_arr.length-1)
          pointer[element] = object_to_put
          return
        end
        
        if pointer[element].nil?
          # We need to create this part of the path
          if builder_path_arr[i+1].is_a?(Fixnum)
            pointer[element] = []
          else
            pointer[element] = {}
          end
        end
        
        pointer = pointer[element]
      end
    else
      builder_path_arr_without_last_element = builder_path_arr.slice(0, builder_path_arr.length - 1)
      obj_at_builder_path = self.get_object_at_builder_path(object_to_modify, builder_path_arr_without_last_element)
      obj_at_builder_path[builder_path_arr.last] = object_to_put
    end
    
  end
  
  def self.process_dynamic_field_value(digital_object_data, value, dynamic_field_header_name, current_builder_path)
    # Note: All dynamic field data goes under a top level key called 'dynamic_field_data'
    # TODO: ['dynamic_field_data'] should probably be a globally-available constant rather than a hard-coded value here
    digital_object_data['dynamic_field_data'] ||= {}
    new_builder_path = dynamic_field_header_name.split(/[:-]/).map{|piece|
      raise 'Dynamic field header names cannot be 0-indexed. Must be 1-indexed.' if piece == '0'
      
      piece.match(/^\d+$/) ? piece.to_i - 1 : piece # This line converts 'name-0:name_role-0:name_role_type' to ['name', 0, 'name_role', 0, 'name_role_type']
    }
    if new_builder_path.last.index('.')
      # Convert ['aaa', 0, 'bbb', 0, 'ccc.ddd'] into ['aaa', 0, 'bbb', 0, 'ccc', 'ddd']
      new_last_two_elements = new_builder_path.pop.split('.') # Temporarily pop and split last element
      new_builder_path += new_last_two_elements # Add new two elements to new_builder_path
    end
    self.put_object_at_builder_path(digital_object_data['dynamic_field_data'], new_builder_path, value, true)
  end

  ##############################
  # Digital Object Data to CSV #
  ##############################

  def self.digital_object_data_to_csv(digital_object_data)

    return ''

  end

end
