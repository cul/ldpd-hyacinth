module Hyacinth::Queue

  DIGITAL_OBJECT_IMPORT = :digital_object_import
  DIGITAL_OBJECT_CSV_EXPORT = :digital_object_csv_export

  QUEUES_IN_DESCENDING_PRIORITY_ORDER = [DIGITAL_OBJECT_CSV_EXPORT, DIGITAL_OBJECT_IMPORT]
  
  def self.process_digital_object_import(digital_object_import_id)
    if HYACINTH['queue_long_jobs']
			Resque.enqueue(ProcessDigitalObjectImportJob, digital_object_import_id)
		else
			ProcessDigitalObjectImportJob.perform(digital_object_import_id)
		end
  end
  
  def self.export_search_results_to_csv(csv_export_id)
    if HYACINTH['queue_long_jobs']
			Resque.enqueue(ExportSearchResultsToCsvJob, csv_export_id)
		else
			ExportSearchResultsToCsvJob.perform(csv_export_id)
		end
  end

end
