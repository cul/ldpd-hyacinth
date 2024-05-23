require 'find'

namespace :hyacinth do
  namespace :deduplication do

    # Example usage:
    # Let's say you have three directories that you want to search through, to find duplicates:
    # 1. /digital/ingest/RBML/Oral_History_Digitized/mellon-audio-pres/corrie-oral-history-staging
    # 2. /ifs/cul/ldpd/fstore/archive/mellon-audio-pres/corrie-oral-history-staging
    # 3. /ifs/cul/ldpd/fstore/archive/preservation/mellon_audio_2010/data
    #
    # And you don't want to include "bagit.txt" files in the results, because you expect that there
    # will be a lot of duplicates of that file, and they'll always have identical content.
    #
    # And you know that Archivematica often generates thumbnail files that don't always have the
    # same name, but DO always have the same image (and therefore same MD5 checksum):
    # 920bb533fb3235c428d6356ab9001740 # this is the checksum to ignore
    #
    # Here's how you would run this task:
    # bundle exec rake dcv:local:find_duplicates RAILS_ENV=dcv_prod \
    # csv_out_file=/home/ldpdserv/mellon-audio-pres-duplicates.csv \
    # paths_to_search=/digital/ingest/RBML/Oral_History_Digitized/mellon-audio-pres/corrie-oral-history-staging,/ifs/cul/ldpd/fstore/archive/mellon-audio-pres/corrie-oral-history-staging,/ifs/cul/ldpd/fstore/archive/preservation/mellon_audio_2010/data
    # filenames_to_skip=bagit.txt \
    # checksums_to_skip=920bb533fb3235c428d6356ab9001740 \
    # regenerate_checksum_file=true
    #
    # Note that if your csv_out_file is located at /home/ldpdserv/mellon-audio-pres-duplicates.csv,
    # this task will also create a /home/ldpdserv/mellon-audio-pres-duplicates.csv.checksums cache
    # file, which stores the pre-deduplication list of all found files and their checksums. This
    # cache file is normally regenerated if you include the regenerate_checksum_file=true argument
    # (as seen above), but if you omit that parameter then the task will re-use the last copy of the
    # checksum file and this will greatly speed up later runs.  Omitting this parameter
    # is helpful in situations when you ran the task over a large number of files and it took a
    # while, but you want to re-run the deduplication with different filenames_to_skip and
    # checksums_to_skip params.
    task :find_duplicates => :environment do
      csv_out_file = ENV['csv_out_file']
      regenerate_checksum_file = ENV['regenerate_checksum_file'] == 'true'
      paths_to_search = ENV['paths_to_search'] && ENV['paths_to_search'] =~ /[^,]+(,[^,]+){0,}/ && ENV['paths_to_search'].split(',')
      # sometimes we want to ignore a certain type of file because it's not important
      # and will result in many duplicates (e.g. bagit.txt)
      filenames_to_skip = (ENV['filenames_to_skip'] && Set.new(ENV['filenames_to_skip'].split(','))) || Set.new
      # sometimes we want to ignore a particular checksum file because it's not important
      # and will result in many duplicates (e.g. Archivematica generic generated thumbnail image)
      checksums_to_skip = (ENV['checksums_to_skip'] && Set.new(ENV['checksums_to_skip'].split(','))) || Set.new

      if !csv_out_file; puts 'Missing required argument: csv_out_file'; next; end
      if !paths_to_search; puts 'Missing or badly-formatted argument: paths_to_search'; next; end

      checksum_csv_path = "#{csv_out_file}.checksums"

      if regenerate_checksum_file || !FileTest.exist?(checksum_csv_path)
        CSV.open(File.join(checksum_csv_path), "wb") do |csv|
          csv << ['md5sum', 'file_path', 'path_group']
          paths_to_search.each do |path_to_search|
            puts "Searching #{path_to_search}..."
            file_counter = 0
            Find.find(path_to_search) do |file_path|
              next if FileTest.directory?(file_path)
              csv << [Digest::MD5.file(file_path).hexdigest, file_path, path_to_search]
              file_counter += 1
              print "\rFiles processed: #{file_counter}"
            end
            puts ''
          end
        end
      else
        puts "Reusing existing checksum file found at: #{checksum_csv_path}"
      end

      checksumpairs_to_result_groups = {}

      CSV.foreach(checksum_csv_path, headers: true) do |checksum_csv_row|
        file_path = checksum_csv_row['file_path']
        filename = File.basename(file_path)
        md5sum = checksum_csv_row['md5sum']
        path_group = checksum_csv_row['path_group']

        next if filenames_to_skip.include?(File.basename(file_path))
        next if checksums_to_skip.include?(File.basename(md5sum))

        checksumpairs_to_result_groups[md5sum] ||= []
        checksumpairs_to_result_groups[md5sum] << { md5sum: md5sum, filename: filename, file_path: file_path, path_group: path_group }
      end

      CSV.open(File.join(csv_out_file), "wb") do |out_csv|
        out_csv << (
          ['md5sum', 'filename(s)'] +
            paths_to_search.map.with_index { |path, ix| "path#{ix+1} - #{path}"} +
            # paths_to_search.map.with_index { |path, ix| "path#{ix+1} - filename+checksum matches under path (> 1 means duplicates WITHIN path)"}
            paths_to_search.map.with_index { |path, ix| "path#{ix+1} - checksum matches under path (> 1 means duplicates WITHIN path)"}
        )

        # filenamechecksumpairs_to_result_groups.values.each do |result_groups|
        checksumpairs_to_result_groups.values.each do |result_groups|
          path_hits_in_each_search_path = []
          path_hit_counts_in_each_search_path = []
          paths_to_search.each.with_index do |search_path, ix|
            hits = result_groups.select { |result_group| result_group[:path_group] == search_path }
            path_hit_counts_in_each_search_path[ix] = hits&.length || 0
            path_hits_in_each_search_path[ix] = hits&.map{ |hit| hit[:file_path] }.join("\n")
          end

          out_csv << (
            [
              result_groups[0][:md5sum],
              result_groups.map{ |result_group| result_group[:filename] }.join("\n")
            ] +
            path_hits_in_each_search_path +
            path_hit_counts_in_each_search_path
          )
        end
      end
    end
  end
end
