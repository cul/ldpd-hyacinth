require "find"
require 'digest/sha1'

class Hyacinth::Utils::BagIt

  def self.validate_bag(bag_directory, print_to_console=false)
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

    puts 'tagmanifest-sha1.txt validation: ' + (tagmanifest_errors.length == 0 ? 'PASS' : "FAIL\n\n" + tagmanifest_errors) if print_to_console

    payload_manifest_errors = ''

    payload_manifest_file = File.open(bag_directory + '/manifest-sha1.txt', 'r')
    total_number_of_files_in_payload_manifest = payload_manifest_file.readlines.size.to_s
    payload_manifest_file.close # Must close files manually when using the method above to open them

    # These next several lines sure do look weird.  What does this do?
    # These lines are important for handling weird file names that have invalid UTF-8 characters in them.
    # When ruby reads in these files and then writes their names to a file, it escapes them (with output
    # that includes things like \226.  When reading these filenames (in a BagIt checksum file) back in
    # for validation, regular Ruby string handling will fail and an error will be raised:
    # "invalid byte sequence in UTF-8".
    # So what we're doing here is unescaping the byte sequences so that they can be handles in
    # ruby String variables.
    # See: http://stackoverflow.com/questions/17832276/using-binary-data-strings-in-utf-8-from-external-file
    data = File.open(bag_directory + '/manifest-sha1.txt', 'rb') { |io|
      contents = io.read.gsub(/\\u([\da-fA-F]{4})/) { |m|
        [$1].pack("H*").unpack("n*").pack("U*")
      }
      contents.split(/\t/)
    }

    counter = 0
    data[0].split("\n").each do |line|
      expected_sha1_checksum_and_file_path = line.strip.split('  ')
      expected_sha1_checksum = expected_sha1_checksum_and_file_path[0]
      file_path = bag_directory + '/' + expected_sha1_checksum_and_file_path[1]
      freshly_calculated_sha1_checksum = Digest::SHA1.hexdigest(File.read(file_path))

      if freshly_calculated_sha1_checksum != expected_sha1_checksum
        payload_manifest_errors << "Failed sha1 checksum validation for file: #{file_path}.  Expected #{expected_sha1_checksum} (from tagmanifest-sha1.txt), but freshly calculated checksum is #{freshly_calculated_sha1_checksum}.\n"
      end

      # Display progress
      print "\r" + 'Comparing payload manifest sha1 checksums to on-disk file checksums... ' + (counter.to_f/total_number_of_files_in_payload_manifest.to_f*100.0).to_i.to_s + '% '
      counter += 1
    end
    print "\rComparing payload manifest sha1 checksums to on-disk file checksums... 100%\n"

    puts 'payload manifest-sha1.txt validation: ' + (payload_manifest_errors.length == 0 ? 'PASS' : "FAIL\n\n" + payload_manifest_errors) if print_to_console

  end

  def self.create_or_update_bag(bag_directory, print_to_console=false)

    puts 'Creating/updating bag at: ' + bag_directory if print_to_console

    # Step 1: Verify that a data directory exists inside bag_directory

    bag_data_directory = bag_directory + '/data'
    # - Report error if no data directory is found
    if( ! File.directory?(bag_data_directory) )
      puts 'Error: Could not find data directory at: ' + bag_data_directory if print_to_console
      return
    end

    # Get list of all files in the data directory
    file_paths = []

    Find.find(bag_data_directory) do |path|
      unless FileTest.directory?(path)
        file_paths << path
      end
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

      print "\r" + 'Calculating payload manifest sha1 checksums and octetstream sums... ' + (counter.to_f/total_number_of_files_in_data_directory.to_f*100.0).to_i.to_s + '% '
      counter += 1
    end
    print "\rCalculating payload manifest sha1 checksums and octetstream sums... 100%\n"

    # Write payload manifest content to file
    File.open(File.join(bag_directory, 'manifest-sha1.txt'), 'w') do |f|
      file_paths_to_sha1_checksums.each do |file_path, sha1_hash|
        f.write(file_paths_to_sha1_checksums[file_path] + '  ' + file_path[bag_directory_string_length+1, file_path.length] + "\n")
      end
    end

    puts "Wrote manifest-sha1.txt (payload sha1 checksums)" if print_to_console

    # Write payload oxum, etc. into bag-info.txt
    File.open(File.join(bag_directory, 'bag-info.txt'), 'w') do |f|
      f.write('Bagging-Date: ' + Time.now.strftime("%Y-%m-%d")  + "\n" + 'Payload-Oxum: ' + total_byte_count.to_s + '.' + total_number_of_files_in_data_directory.to_s)
    end

    puts "Wrote bag-info.txt (Bagging-Date, Payload-Oxum and total number of files)" if print_to_console

    # Write out bagit.txt file
    File.open(File.join(bag_directory, 'bagit.txt'), 'w') do |f|
      f.write("BagIt-version: 0.97\nTag-File-Character-Encoding: UTF-8")
    end
    puts "Wrote bagit.txt (bagit spec version)" if print_to_console

    # Calculate and write out new tagmanifest-sha1.txt (checksums for all non-data-directory stuff)
    file_paths_to_checksum_for_tagmanifest = ['manifest-sha1.txt', 'bag-info.txt', 'bagit.txt']
    File.open(File.join(bag_directory, 'tagmanifest-sha1.txt'), 'w') do |f|
      file_paths_to_checksum_for_tagmanifest.each do |non_data_file_path|
        f.write( Digest::SHA1.hexdigest(File.read(File.join(bag_directory, non_data_file_path))) + '  ' + non_data_file_path + "\n")
      end
    end
    puts "Wrote tagmanifest-sha1.txt (sha1 checksums for manifest-sha1.txt, bag-info.txt, and bagit.txt)" if print_to_console

  end

  # When ruby handles unicode characters from the filesystem and writes those into a file, it escapes them.
  # So when we're reading those escaped sequences from the file again, we need to unescape the sequences so
  # we can handle them as a string again
  def self.unescape_unicode(string_to_unescape)
    string_to_unescape.gsub(/\\u([\da-fA-F]{4})/) { |m|
      [$1].pack("H*").unpack("n*").pack("U*")
    }
    return string_to_unescape
  end

end

#def print_usage_statement
#  puts 'Usage:'
#  puts '    ruby bagit.rb [create_bag|validate_bag] [path_to_bag]'
#end
#
#if ARGV.length == 0
#  print_usage_statement()
#else
#  command = ARGV[0]
#  bag_directory = ARGV[1]
#
#  if command == 'create_bag'
#    BagIt::create_bag(bag_directory, true)
#  elsif command == 'validate_bag'
#    BagIt::validate_bag(bag_directory, true)
#  else
#    puts 'Unknown command: ' + command
#  end
#end
