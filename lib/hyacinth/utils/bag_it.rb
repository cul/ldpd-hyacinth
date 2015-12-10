require "find"
require 'digest/sha1'

class Hyacinth::Utils::BagIt
  extend Logger::Behavior

  PAYLOAD_COMPARISON_PROGRESS = 'Comparing payload manifest sha1 checksums to on-disk file checksums... %f2%'

  def self.validate_bag(bag_directory, debug = false)
    # First check files listed in tagmanifest-sha1.txt

    tagmanifest_errors = ''

    File.open(bag_directory + '/tagmanifest-sha1.txt', 'r') do |f|
      f.each_line do |line|
        expected_sha1_checksum_and_file_path = line.strip.split('  ')
        expected_sha1_checksum = expected_sha1_checksum_and_file_path[0]
        file_path = bag_directory + '/' + expected_sha1_checksum_and_file_path[1]
        freshly_calculated_sha1_checksum = Digest::SHA1.hexdigest(File.read(file_path))

        if freshly_calculated_sha1_checksum != expected_sha1_checksum
          tagmanifest_errors << "Failed sha1 checksum validation for file: #{file_path}.  Expected #{expected_sha1_checksum} (from tagmanifest-sha1.txt), but freshly calculated checksum is #{freshly_calculated_sha1_checksum}.\n"
        end
      end
    end

    logger.debug('tagmanifest-sha1.txt validation: ' + (tagmanifest_errors.length == 0 ? 'PASS' : "FAIL\n\n" + tagmanifest_errors)) if debug

    # These next several lines sure do look weird.  What does this do?
    # These lines are important for handling weird file names that have invalid UTF-8 characters in them.
    # When ruby reads in these files and then writes their names to a file, it escapes them (with output
    # that includes things like \226.  When reading these filenames (in a BagIt checksum file) back in
    # for validation, regular Ruby string handling will fail and an error will be raised:
    # "invalid byte sequence in UTF-8".
    # So what we're doing here is unescaping the byte sequences so that they can be handles in
    # ruby String variables.
    # See: http://stackoverflow.com/questions/17832276/using-binary-data-strings-in-utf-8-from-external-file
    data = File.open(bag_directory + '/manifest-sha1.txt', 'rb') do |io|
      contents = io.read.gsub(/\\u([\da-fA-F]{4})/) do |m|
        [m[1]].pack("H*").unpack("n*").pack("U*")
      end
      contents.split(/\t/)
    end

    payload_manifest_errors = validate_payload_checksums(data[0].split("\n"))

    logger.debug('payload manifest-sha1.txt validation: ' + (payload_manifest_errors.length == 0 ? 'PASS' : "FAIL\n\n" + payload_manifest_errors)) if debug
  end

  def self.validate_payload_checksums(lines)
    payload_manifest_errors = ''
    counter = 0
    lines.each do |line|
      expected_sha1_checksum_and_file_path = line.strip.split('  ')
      expected_sha1_checksum = expected_sha1_checksum_and_file_path[0]
      file_path = bag_directory + '/' + expected_sha1_checksum_and_file_path[1]
      freshly_calculated_sha1_checksum = Digest::SHA1.hexdigest(File.read(file_path))

      if freshly_calculated_sha1_checksum != expected_sha1_checksum
        payload_manifest_errors << "Failed sha1 checksum validation for file: #{file_path}.  Expected #{expected_sha1_checksum} (from tagmanifest-sha1.txt), but freshly calculated checksum is #{freshly_calculated_sha1_checksum}.\n"
      end

      # Display progress
      percentage = (counter.to_f / lines.size.to_f * 100.0)
      logger.info(PAYLOAD_COMPARISON_PROGRESS % percentage)
      counter += 1
    end
    logger.info(PAYLOAD_COMPARISON_PROGRESS % 100.0)
    payload_manifest_errors
  end

  def self.create_or_update_bag(bag_directory,  debug = false)
    logger.debug('Creating/updating bag at: ' + bag_directory) if debug

    # Step 1: Verify that a data directory exists inside bag_directory

    bag_data_directory = bag_directory + '/data'
    # - Report error if no data directory is found
    unless File.directory?(bag_data_directory)
      logger.debug('Error: Could not find data directory at: ' + bag_data_directory) if debug
      return
    end

    # Get list of all files in the data directory
    file_paths = []

    Find.find(bag_data_directory) do |path|
      file_paths << path unless FileTest.directory?(path)
    end

    total_number_of_files_in_data_directory = file_paths.length
    file_paths_to_sha1_checksums = {}

    # For each file, calculate a checksum and keep a running total of the file byte counts
    counter = 0
    total_byte_count = 0
    bag_directory_string_length = bag_directory.length
    file_paths.each do |file_path|
      file_paths_to_sha1_checksums[file_path] = Digest::SHA1.hexdigest(File.read(file_path))
      total_byte_count += File.size(file_path)

      logger.info('Calculating payload manifest sha1 checksums and octetstream sums... ' + (counter.to_f / total_number_of_files_in_data_directory.to_f * 100.0).to_i.to_s + '% ')
      counter += 1
    end
    logger.info('Calculating payload manifest sha1 checksums and octetstream sums... 100%')

    # Write payload manifest content to file
    File.open(File.join(bag_directory, 'manifest-sha1.txt'), 'w') do |f|
      file_paths_to_sha1_checksums.each do |file_path, sha1_hash|
        f.write(sha1_hash + '  ' + file_path[bag_directory_string_length + 1, file_path.length] + "\n")
      end
    end

    logger.debug("Wrote manifest-sha1.txt (payload sha1 checksums)") if debug

    write_bag_info(bag_directory, total_number_of_files_in_data_directory, total_byte_count, debug)

    write_bagit(bag_directory, debug)

    write_tag_manifest(bag_directory, debug)
  end

  def write_bag_info(bag_directory, payload_count, payload_size, debug = false)
    # Write payload oxum, etc. into bag-info.txt
    File.open(File.join(bag_directory, 'bag-info.txt'), 'w') do |f|
      f.write('Bagging-Date: ' + Time.now.strftime("%Y-%m-%d") + "\n" + 'Payload-Oxum: ' + payload_size.to_s + '.' + payload_count.to_s)
    end

    logger.debug("Wrote bag-info.txt (Bagging-Date, Payload-Oxum and total number of files)") if debug
  end

  def write_bagit(bag_directory, debug = false)
    # Write out bagit.txt file
    File.open(File.join(bag_directory, 'bagit.txt'), 'w') do |f|
      f.write("BagIt-version: 0.97\nTag-File-Character-Encoding: UTF-8")
    end
    logger.debug("Wrote bagit.txt (bagit spec version)") if debug
  end

  def write_tag_manifest(bag_directory, debug = false)
    # Calculate and write out new tagmanifest-sha1.txt (checksums for all non-data-directory stuff)
    file_paths_to_checksum_for_tagmanifest = ['manifest-sha1.txt', 'bag-info.txt', 'bagit.txt']
    File.open(File.join(bag_directory, 'tagmanifest-sha1.txt'), 'w') do |f|
      file_paths_to_checksum_for_tagmanifest.each do |non_data_file_path|
        f.write(Digest::SHA1.hexdigest(File.read(File.join(bag_directory, non_data_file_path))) + '  ' + non_data_file_path + "\n")
      end
    end
    logger.debug("Wrote tagmanifest-sha1.txt (sha1 checksums for manifest-sha1.txt, bag-info.txt, and bagit.txt)") if debug
  end
end
