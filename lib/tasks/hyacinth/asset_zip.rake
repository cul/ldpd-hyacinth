datastreams_to_asset_file_location_heading_names = {
  'master' => '_asset_data.filesystem_location',
  'service' => '_asset_data.service_copy_location',
  'access' => '_asset_data.access_copy_location',
  'poster' => '_asset_data.poster_location',
}

require 'csv'
require 'zip'

namespace :hyacinth do
  namespace :asset_zip do
    task :from_hyacinth_csv_export => :environment do
      required_asset_zip_column_headings = ['_asset_data.original_filename']

      hyacinth_csv_file_path = ENV['hyacinth_csv_file_path']
      puts 'Missing required parameter: hyacinth_csv_file_path' if hyacinth_csv_file_path.nil?
      output_file_path = ENV['output_file_path']
      puts 'Missing required parameter: output_file_path' if output_file_path.nil?
      datastream = ENV['datastream']
      if datastream.nil?
        puts 'Missing required parameter: datastream'
      elsif !(datastreams_to_asset_file_location_heading_names.keys.include?(datastream))
        puts "Invalid value supplies for parameter datastream.  Must be one of: #{datastreams_to_asset_file_location_heading_names.keys.join(', ')}"
        datastream = nil
      end
      next if hyacinth_csv_file_path.nil? || output_file_path.nil? || datastream.nil?

      raise "File not found: #{hyacinth_csv_file_path}" unless File.exist?(hyacinth_csv_file_path)

      # Select appropriate file location heading, based on selected datastream
      file_location_heading = datastreams_to_asset_file_location_heading_names[datastream]
      # Add file location header to list of required headings
      required_asset_zip_column_headings << file_location_heading

      puts "Reading #{hyacinth_csv_file_path} ..."

      # Even though Hyacinth 2 exports double-header CSV files, this script expects only single-header
      # files. So double header files need to be cleaned up before they're processed by this script
      # (i.e. the human-readable header row just needs to be deleted).
      # We'll verify this by ensuring that the CSV file we're given has all required column headings
      # in the first row, which is an additional requirement anyway.

      csv_is_valid = false
      CSV.foreach(hyacinth_csv_file_path) do |row|
        csv_is_valid = true if (row & required_asset_zip_column_headings).length == 2
      end

      raise "This CSV is not compatible with this task.  "\
            "It must contain all of the following column headings in the first row: " +
            required_asset_zip_column_headings.join(', ') unless csv_is_valid

            file_locations_to_file_names = {}

      # Keep an eye out for duplicate values (and warn, if we find them)
      file_locations = Set.new
      new_file_names = Set.new

      CSV.foreach(hyacinth_csv_file_path, headers: true) do |row|
        original_filename = row["_asset_data.original_filename"]
        file_location = row[file_location_heading]
        raise "Error: No original filename available in spreadsheet for #{file_location}" if original_filename.nil? || original_filename.empty?

        # To generate new filename, replace original filename extension with access copy extension
        new_file_name = File.basename(original_filename).gsub(File.extname(original_filename), File.extname(file_location))

        raise "Error: Encountered duplicate access copy location: #{file_location}" if file_locations.include?(file_location)
        file_locations << file_location

        raise "Error: Encountered duplicate original file name: #{original_filename}" if new_file_names.include?(new_file_name)
        new_file_names << original_filename

        file_locations_to_file_names[file_location] = new_file_name
      end

      if output_file_path.end_with?('.zip')
        # If zip output file already exists, prompt to delete
        if File.exist?(output_file_path)
          print "An existing file was found at: #{output_file_path}.  Okay to delete it? (y/n) "
          if(STDIN.gets.strip != 'y')
            puts 'A value other than "y" was entered.  Exiting.'
            exit
          end
          puts "Deleted #{output_file_path}"
          File.delete(output_file_path)
        end

        puts "Writing assets to zip file: #{output_file_path} ..."

        Zip::File.open(output_file_path, Zip::File::CREATE) do |zipfile|
          file_locations_to_file_names.each do |file_path, new_filename_in_archive|
            # Two arguments:
            # - The name of the file as it will appear in the archive
            # - The original file, including the path to find it
            puts "Adding: #{file_path} as #{new_filename_in_archive}"
            zipfile.add(new_filename_in_archive, file_path)
          end
        end
      else
        # If directory already exists at this location, confirm action
        if Dir.exist?(output_file_path)
          print "An existing directory was found at: #{output_file_path}.  Continue anyway? (y/n) "
          if(STDIN.gets.strip != 'y')
            puts 'A value other than "y" was entered.  Exiting.'
            exit
          end
        end

        puts "Writing assets to directory: #{output_file_path} ..."
        FileUtils.mkdir_p(output_file_path)

        puts 'Writing asset files to folder...'

	file_locations_to_file_names.each do |file_path, new_filename_in_directory|
	  puts "Copying: #{file_path} as #{new_filename_in_directory}"
	  FileUtils.cp(file_path, File.join(output_file_path, new_filename_in_directory))
	end
      end

      puts "Done!"
    end
  end
end
