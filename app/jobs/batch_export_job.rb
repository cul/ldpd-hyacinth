# frozen_string_literal: true

class BatchExportJob
  @queue = :batch_exports

  BATCH_SIZE = 10
  PROCESSED_RECORD_COUNT_UPDATE_FREQUENCY = 100
  COPY_OPERATION_READ_BUFFER_SIZE = 5.megabytes

  def self.perform(batch_export_id)
    start_time = Time.current
    records_processed = 0
    batch_export = BatchExport.find(batch_export_id)

    # We can't write directly to batch export storage because the CSV class expects disk, and our
    # storage isn't guaranteed to be disk (could be memory, remote server, etc.), so we'll write to
    # a tempfile and then later on, copy that complete tempfile's contents to batch export storage.
    unordered_headers_temp_csv_file = Tempfile.new('unordered-headers-batch-export')
    # We will reorder columns and write to another temporary csv after we're done.
    ordered_headers_temp_csv_file = Tempfile.new('ordered-headers-batch-export')

    CSV.open(unordered_headers_temp_csv_file.path, 'wb') do |csv|
      digital_objects_for_batch_export(batch_export) do |digital_object|
        update_export_progress_info_on_frequency_modulus(batch_export, records_processed += 1, start_time)
        csv << [digital_object.uid]
      end
    end

    unodered_csv_to_ordered_csv(unordered_headers_temp_csv_file, ordered_headers_temp_csv_file, {})

    file_location = Hyacinth::Config.batch_export_storage
                                    .primary_storage_adapter
                                    .generate_new_location_uri("#{batch_export.id}.csv")

    write_csv_to_storage(ordered_headers_temp_csv_file, Hyacinth::Config.batch_export_storage, file_location)
    handle_job_success(batch_export, start_time, records_processed, file_location)
  rescue StandardError => e
    handle_job_error(batch_export, e)
  ensure
    # Close and unlink our tempfiles
    unordered_headers_temp_csv_file.close!
    ordered_headers_temp_csv_file.close!
  end

  # Converts the unordered headers csv file into a new csv file with ordered headers
  # @param unordered_headers_temp_csv_file [File] Input unordered headers CSV file
  # @param ordered_headers_temp_csv_file [File] Output ordered headers CSV file
  # @param ordered_headers_temp_csv_file [Hash] Mapping of header names to 0-indexed column indexes
  # @return [void]
  def self.unodered_csv_to_ordered_csv(unordered_headers_temp_csv_file, ordered_headers_temp_csv_file, _headers_to_indexes)
    # TODO: Real implementation. Right now we're just copying the unordered CSV content to the output file.
    unordered_headers_temp_csv_file.rewind

    while (chunk = unordered_headers_temp_csv_file.read(COPY_OPERATION_READ_BUFFER_SIZE))
      ordered_headers_temp_csv_file.write(chunk)
    end
  end

  def self.write_csv_to_storage(csv_file, storage, file_location)
    csv_file.rewind
    storage.with_writable(file_location) do |io|
      while (chunk = csv_file.read(COPY_OPERATION_READ_BUFFER_SIZE))
        io.write(chunk)
      end
    end
  end

  # Updates the batch_export's number_of_records_processed and duration properties when
  # number_of_records_processed is a multiple of PROCESSED_RECORD_COUNT_UPDATE_FREQUENCY
  # @return [void]
  def self.update_export_progress_info_on_frequency_modulus(batch_export, records_processed, start_time)
    return unless (records_processed % PROCESSED_RECORD_COUNT_UPDATE_FREQUENCY).zero?
    batch_export.update(
      number_of_records_processed: records_processed,
      duration: (Time.current - start_time).to_i
    )
  end

  def self.handle_job_success(batch_export, start_time, records_processed, file_location)
    batch_export.duration = (Time.current - start_time).to_i
    batch_export.number_of_records_processed = records_processed
    batch_export.file_location = file_location
    batch_export.success!
  end

  def self.handle_job_error(batch_export, error)
    batch_export.export_errors << error.message + "\n\n" + error.backtrace.join("\n")
    batch_export.failure!
  end

  # Given a batch_export, calls the given block once for each digital object returned by executing
  # a digital object search for the batch_export's search_params.
  # @param [BatchExport] A BatchExport object.
  # @yield [digital_object] A DigitalObject::Base subclass instance.
  # @return [void]
  def self.digital_objects_for_batch_export(batch_export)
    search_params = JSON.parse(batch_export.search_params)

    # TODO: Pass user into search method (when that functionality exists) so that we scope export
    # to only projects that the user has permission to read.
    # OR: Add an fq on a user's readable projects so that search results only return things that
    # the user should see. (We're not currently indexing projects, so this isn't possible right now.)

    # TODO: Eventually the results object avove will be a DigitalObjectSearchResult (or similar)
    # type of object instead of a solr response. At that point, we'll refactor this code.
    results = Hyacinth::Config.digital_object_search_adapter.search(search_params) do |solr_params|
      solr_params.rows(BATCH_SIZE)
      solr_params.start(0)
    end
    total_records_to_process = results['response']['numFound']
    return if total_records_to_process.zero?

    batch_export.total_records_to_process = total_records_to_process
    batch_export.in_progress!

    batch_counter = 1
    there_are_more_records = true

    while there_are_more_records
      results['response']['docs'].each do |doc|
        yield DigitalObject::Base.find(doc['id'])
      end

      results = Hyacinth::Config.digital_object_search_adapter.search(search_params) do |solr_params|
        solr_params.rows(BATCH_SIZE)
        solr_params.start(BATCH_SIZE * batch_counter)
      end

      there_are_more_records = results['response']['docs'].present?
      batch_counter += 1
    end
  end
end
