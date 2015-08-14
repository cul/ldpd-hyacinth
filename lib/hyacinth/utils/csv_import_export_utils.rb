class Hyacinth::Utils::CsvImportExportUtils

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
      digital_object_data = {}
      row.each_with_index do |cell_value,index|

        next if cell_value.blank?

        if column_indices_to_headers[index].start_with?('_')
          digital_object_data[ column_indices_to_headers[index] ] ||= []
          digital_object_data[ column_indices_to_headers[index] ] << cell_value
        end

      end

      digital_object_data_results << digital_object_data unless digital_object_data.blank?

    end
    
    return digital_object_data_results

  end

  def self.digital_object_data_to_csv(digital_object_data)

    return ''

  end

end
