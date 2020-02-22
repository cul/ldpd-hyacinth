class BatchExportJob
  @queue = :export_jobs

  BATCH_SIZE = 10

  def self.perform(batch_export_id)
    start_time = Time.now
    digital_objects_for_batch_export(BatchExport.find(batch_export_id)) do |digital_object|
      puts digital_object.uid
    end
  end

  def self.digital_objects_for_batch_export(batch_export, &block)
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
