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
  
  def self.put_object_at_builder_path(object_to_modify, builder_path_arr, object_to_put, create_missing_path=false)
    
    raise 'When adding an object, your builder path cannot end with a specific array index (e.g. ["a", 3]). Specify the location of an array object to append the new object to that array.' if builder_path_arr.last.is_a?(Fixnum)
    
    obj_at_builder_path = self.get_object_at_builder_path(object_to_modify, builder_path_arr)
    raise 'Path not found.  To create path, pass a value true to the create_missing_path method parameter.' if obj_at_builder_path.nil? && (! create_missing_path)
    
    if obj_at_builder_path.nil?
      # There is no object at this builder path.  Let's build the path.
      partial_builder_path_arr = [] # title
      
      # Traverse the object, starting at the top of the hierarchy, to build the path as needed
      builder_path_arr.each do |element|
        partial_builder_path_arr.push(element)
        
        # Verify that an object exists as we move down the chain
        possible_object_at_partial_builder_path = self.get_object_at_builder_path(object_to_modify, partial_builder_path_arr)
        if possible_object_at_partial_builder_path
          next
        else
          # Note: For the final elemen, we don't want to include a zero-index hash because we don't plan to add anything to it
          reached_max_required_depth = partial_builder_path_arr.length == builder_path_arr.length
          
          latest_key = partial_builder_path_arr.pop
          self.get_object_at_builder_path(object_to_modify, partial_builder_path_arr)[latest_key] = reached_max_required_depth ? [] : [{}]
          partial_builder_path_arr.push(latest_key)
        end
      end
      
    end
    
    # Object at builder path exists at this point.  It either already existed or was just created.  Let's add the new object_to_put to it.
    obj_at_builder_path ||= self.get_object_at_builder_path(object_to_modify, partial_builder_path_arr)
    
    # Note: obj_at_builder_path is always an array because it's not possible to give a builder_path that ends with an array index
    obj_at_builder_path.push(object_to_put)
  end
  
  def self.process_dynamic_field_value(digital_object_data, value, dynamic_field_header_name, current_builder_path)
    
    new_builder_path = dynamic_field_header_name.split(':')
    new_dynamic_field_name = new_builder_path.pop
    
    puts 'new_builder_path: ' + new_builder_path.inspect
    puts 'new_dynamic_field_name: ' + new_dynamic_field_name.inspect
    
    # At this point, new_builder_path is ['title']
    # At this point, new_dynamic_field_name is 'title_non_sort_portion'
    
    object_at_builder_path = self.get_object_at_builder_path(digital_object_data, new_builder_path)
    if object_at_builder_path
      current_builder_path = new_builder_path # TODO: Is this necessary? No change?
      object_at_builder_path[new_dynamic_field_name] = value
    else
      new_obj = {}
      new_obj[new_dynamic_field_name] = value
      self.put_object_at_builder_path(digital_object_data, new_builder_path, new_obj, true)
      current_builder_path = new_builder_path.push(self.get_object_at_builder_path(digital_object_data, new_builder_path).length)
    end
    
    #current_builder_path = ['title', 0]
    #
    #jpath = JsonPath.new('$')
    
    #{
    #  "title":[]
    #}
    #
    #{
    #  "title":[
    #    {}
    #  ]
    #}
    #
    #{
    #  "title":[
    #    {
    #      "title_non_sort_portion" : "The"
    #    }
    #  ]
    #}
    #
    ## Pointer location: ['title'][0]
    #pointer = ['title', 0]
    #
    ## Next header value -> title:sort_portion
    ## Means: ['title'][0]
    #
    #{
    #  "title":[]
    #}
    #
    #{
    #  "title":[
    #    {}
    #  ]
    #}
    #
    #{
    #  "title":[
    #    {
    #      "title_non_sort_portion" : "The"
    #    }
    #  ]
    #}
    #
    ## Pointer location: ['title'][0]
    #
    
    
    
    # Current builder path is ['title']
    # New goal path is: ['name']
    # Need to determine difference
    #Difference is: ['name']
    
    #Found: name:name_value
    #new_builder_path = dynamic_field_header_name.split(':') # e.g. ['name']
    #new_dynamic_field_name = new_dynamic_field_group_path.pop # e.g. 'name_value'
    #
    #builder_path_difference = self.get_builder_path_difference(current_builder_path, new_builder_path) # returns ['name']
    
    
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

  ##############################
  # Digital Object Data to CSV #
  ##############################

  def self.digital_object_data_to_csv(digital_object_data)

    return ''

  end

end
