# frozen_string_literal: true

class BatchExportJob
  @queue = :export_jobs

  BATCH_SIZE = 10
  PROCESSED_RECORD_COUNT_UPDATE_FREQUENCY = 100

  def self.perform(batch_export_id)
    start_time = Time.current
    batch_export = BatchExport.find(batch_export_id)
    records_processed = 0
    digital_objects_for_batch_export(batch_export) do |digital_object|
      Rails.logger.debug(digital_object.uid)
      records_processed += 1
      batch_export.update(number_of_records_processed: records_processed) if (records_processed % PROCESSED_RECORD_COUNT_UPDATE_FREQUENCY).zero?
    end
    batch_export.duration = (Time.current - start_time).to_i
    batch_export.number_of_records_processed = records_processed
    batch_export.success!
    raise StandardError, 'Oh no! An error!'
  rescue StandardError => e
    batch_export.export_errors << e.message + "\n\n" + e.backtrace.join("\n")
    batch_export.failure!
  end

  # Given a batch_export, calls the given block once for each digital object returned by executing
  # a digital object search for the batch_export's search_params.
  # @param [BatchExport] A BatchExport object.
  # @yield [digital_object] A DigitalObject::Base subclass instance.
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
