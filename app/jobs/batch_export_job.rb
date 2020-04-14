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

    begin
      # We can't write directly to batch export storage because the CSV class expects disk, and our
      # storage isn't guaranteed to be disk (could be memory, remote server, etc.), so we'll write to
      # a tempfile and then later on, copy that complete tempfile's contents to batch export storage.
      ordered_headers_temp_csv_file = Tempfile.new('ordered-headers-batch-export')

      JsonCsv.create_csv_for_json_records(ordered_headers_temp_csv_file.path) do |csv_builder|
        digital_objects_for_batch_export(batch_export) do |digital_object|
          csv_builder.add(digital_object_as_export(digital_object))
          update_export_progress_info_on_frequency_modulus(batch_export, records_processed += 1, start_time)
        end
      end

      file_location = Hyacinth::Config.batch_export_storage
                                      .primary_storage_adapter
                                      .generate_new_location_uri("#{batch_export.id}.csv")

      write_csv_to_storage(ordered_headers_temp_csv_file, Hyacinth::Config.batch_export_storage, file_location)
      handle_job_success(batch_export, start_time, records_processed, file_location)
    rescue StandardError => e
      handle_job_error(batch_export, e, start_time)
    ensure
      # Close and unlink our tempfile
      ordered_headers_temp_csv_file.close!
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
    batch_export.duration = [1, (Time.current - start_time).to_i].max
    batch_export.number_of_records_processed = records_processed
    batch_export.file_location = file_location
    batch_export.success!
  end

  def self.handle_job_error(batch_export, error, start_time)
    batch_export.duration = [1, (Time.current - start_time).to_i].max
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
    searching_user = batch_export.user

    # TODO: Pass user into search method (when that functionality exists) so that we scope export
    # to only projects that the user has permission to read.
    # OR: Add an fq on a user's readable projects so that search results only return things that
    # the user should see. (We're not currently indexing projects, so this isn't possible right now.)

    # TODO: Eventually the results object avove will be a DigitalObjectSearchResult (or similar)
    # type of object instead of a solr response. At that point, we'll refactor this code.
    results = Hyacinth::Config.digital_object_search_adapter.search(search_params, searching_user) do |solr_params|
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

      results = Hyacinth::Config.digital_object_search_adapter.search(search_params, searching_user) do |solr_params|
        solr_params.rows(BATCH_SIZE)
        solr_params.start(BATCH_SIZE * batch_counter)
      end

      there_are_more_records = results['response']['docs'].present?
      batch_counter += 1
    end
  end

  # Converts a DigitalObject to a JSON-like hash structure appriate for the CSV export process.
  def self.digital_object_as_export(digital_object)
    # Convert to hash with string keys
    dobj_as_hash = digital_object.as_json.deep_stringify_keys

    # Remove dynamic_field_data so we can handle them separately
    dynamic_field_data = dobj_as_hash.delete('dynamic_field_data')

    # Build new hash with all remaining keys prefixed with an underscore
    hash_to_return = {}
    dobj_as_hash.each do |key, value|
      hash_to_return["_#{key}"] = value
    end

    # Assign all dynamic_field_data key-value pairs to the top level
    dynamic_field_data.each do |key, value|
      hash_to_return[key] = value
    end

    hash_to_return
  end
end
