class ExportSearchResultsToCsvJob

  @queue = Hyacinth::Queue::DIGITAL_OBJECT_CSV_EXPORT

  def self.perform(csv_export_id)
    
    csv_export = CsvExport.find(csv_export_id)
    user = csv_export.user
    search_params = JSON.parse(csv_export.search_params)
    path_to_csv_file = File.join(HYACINTH['csv_export_directory'], "export-#{csv_export.id}-#{Time.now.strftime('%Y%m%d_%H%M%S')}.csv")
    
    # We run through the data two times. There's probably a better way, but here's why:
    # Pass 1: Collect all field names and determine the max number of instances of each field (e.g. spreadsheet may need 3 alternate_title fields or 4 name fields)
    # Pass 2: Collect the data and place it in the appropriate column
    
    column_names_to_column_indexes = {}
    
    # Create temporary CSV file that contains data, but no headers.
    # Headers will gathere in memory, and then sorted later on.
    # Then the final CSV will be generated from the in-memory headers
    # and the temporary CSV file.
    CSV.open(path_to_csv_file + '.tmp', 'wb') do |csv|
      DigitalObject::Base::search_in_batches(search_params, user, 50) do |digital_object_data|
        row = []
        
        ### Handle core fields
        
        # pid
        column_names_to_column_indexes['_pid'] = column_names_to_column_indexes.length unless column_names_to_column_indexes.has_key?('_pid')
        row[column_names_to_column_indexes['_pid']] = digital_object_data['pid']
        #project
        column_names_to_column_indexes['_project.string_key'] = column_names_to_column_indexes.length unless column_names_to_column_indexes.has_key?('_project.string_key')
        row[column_names_to_column_indexes['_project.string_key']] = digital_object_data['project']['string_key']
        
        # identifiers
        digital_object_data['identifiers'].each_with_index do |identifier, identifier_index|
          column_names_to_column_indexes["_identifiers-#{identifier_index+1}"] = column_names_to_column_indexes.length unless column_names_to_column_indexes.has_key?("_identifiers-#{identifier_index+1}")
          row[column_names_to_column_indexes["_identifiers-#{identifier_index+1}"]] = identifier
        end
        # publish_targets
        digital_object_data['publish_targets'].each_with_index do |publish_target, publish_target_index|
          column_names_to_column_indexes["_publish_targets-#{publish_target_index+1}"] = column_names_to_column_indexes.length unless column_names_to_column_indexes.has_key?("_publish_targets-#{publish_target_index+1}")
          row[column_names_to_column_indexes["_publish_targets-#{publish_target_index+1}"]] = publish_target
        end
        
        # asset-only fields
        if self.is_a?(DigitalObject::Asset)
          column_names_to_column_indexes['_asset_data.filesystem_location'] = column_names_to_column_indexes.length unless column_names_to_column_indexes.has_key?('_asset_data.filesystem_location')
          row[column_names_to_column_indexes['_asset_data.filesystem_location']] = digital_object_data['asset_data.filesystem_location']
          
          column_names_to_column_indexes['_asset_data.checksum'] = column_names_to_column_indexes.length unless column_names_to_column_indexes.has_key?('_asset_data.checksum')
          row[column_names_to_column_indexes['_asset_data.checksum']] = digital_object_data['asset_data.checksum']
        end
        
        ### Handle dyanmic fields
        DigitalObject::Base.recursively_generate_csv_style_flattened_dynamic_field_data(digital_object_data['dynamic_field_data'], true).each do |csv_header_path, value|
          next if csv_header_path.ends_with?('.vocabulary_string_key') # For controlled fields, skip the 'vocabulary_string_key' field because it's not helpful
          next if csv_header_path.ends_with?('.type') # For controlled fields, skip the 'type' field because it's not helpful
          
          column_names_to_column_indexes[csv_header_path] = column_names_to_column_indexes.length unless column_names_to_column_indexes.has_key?(csv_header_path)
          row[column_names_to_column_indexes[csv_header_path]] = value
        end
        
        # Write entire row to CSV file
        csv << row
      end
    end
        
    # Sort column names and store name-to-numeric-index mapping in sorted_column_names_to_column_indexes
    sorted_column_names_to_column_indexes = {}
    
    # First collect all fields that start with underscore and
    
    separator_regex = Regexp.new('[-:.]')
    column_names_to_column_indexes.keys.sort {|a, b|
      
      if a == '_pid'
        # Always sort _pid first
        next -1
      elsif b == '_pid'
        # Always sort _pid first
        next 1
      elsif a.start_with?('_') && ! b.start_with?('_')
        # Always sort underscore fields before non-underscore fields first
        next -1
      elsif ! a.start_with?('_') && b.start_with?('_')
        # Always sort underscore fields before non-underscore fields first
        next 1
      else
        # Comparison with either two underscore fields or
        # two non-underscore fields. We'll break the field
        # into pieces (and cast numeric values into integers
        # for proper integer comparison) and compare each piece.
        a_arr = a.split(separator_regex).each {|el| el.to_i.to_s == el ? el.to_i : el.to_s}
        b_arr = b.split(separator_regex).each {|el| el.to_i.to_s == el ? el.to_i : el.to_s}
        
        min_array_length = [a.length, b.length].min
        
        arr_comparison_result = nil
        min_array_length.times { |i|
          if a_arr[i] > b_arr[i]
            arr_comparison_result = 1
          elsif a_arr[i] < b_arr[i]
            arr_comparison_result = -1
          end
          break unless arr_comparison_result.nil?
        }
        
        if arr_comparison_result.nil?
          next 0 # The two values are completely equal
        else
          next arr_comparison_result
        end
      end
    }.each do |key|
      sorted_column_names_to_column_indexes[key] = column_names_to_column_indexes[key]
    end
    
    # Open new CSV for writing
    CSV.open(path_to_csv_file, 'wb') do |final_csv|
      
      # Write out column headers
      final_csv << sorted_column_names_to_column_indexes.keys
      
      # Open temporary CSV for reading
      CSV.open(path_to_csv_file + '.tmp', 'rb') do |temp_csv|
        # Copy and reorder row data from temp csv to final csv
        
        temp_csv.each do |temp_csv_row|
          
          reordered_temp_csv_row = []
          sorted_column_names_to_column_indexes.each_pair do |column_name, row_index|
            reordered_temp_csv_row << temp_csv_row[row_index]
          end
          
          final_csv << reordered_temp_csv_row
        end
      end
    end
    
    # Delete temporary CSV
    FileUtils.rm(path_to_csv_file + '.tmp')
    
    csv_export.path_to_csv_file = path_to_csv_file
    #csv_export.status.success!
    csv_export.save
  end

end
