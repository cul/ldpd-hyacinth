module Hyacinth::Queue
  DIGITAL_OBJECT_IMPORT_HIGH = :digital_object_import_high
  DIGITAL_OBJECT_IMPORT_MEDIUM = :digital_object_import_medium
  DIGITAL_OBJECT_IMPORT_LOW = :digital_object_import_low
  REPUBLISH_ASSET = :republish_asset
  DIGITAL_OBJECT_CSV_EXPORT = :digital_object_csv_export
  DIGITAL_OBJECT_REINDEX = :digital_object_reindex
  IMAGE_SERVICE = :image_service
  REQUEST_DERIVATIVES = :request_derivatives

  QUEUES_IN_DESCENDING_PRIORITY_ORDER = [
    IMAGE_SERVICE,
    REQUEST_DERIVATIVES,
    DIGITAL_OBJECT_CSV_EXPORT,
    DIGITAL_OBJECT_IMPORT_HIGH,
    DIGITAL_OBJECT_IMPORT_MEDIUM,
    DIGITAL_OBJECT_IMPORT_LOW,
    DIGITAL_OBJECT_REINDEX,
    REPUBLISH_ASSET
  ]

  def self.process_digital_object_import(digital_object_import)
    digital_object_import_id = digital_object_import.id
    priority = digital_object_import.import_job.priority.to_sym

    if HYACINTH[:queue_long_jobs]
      case priority
      when :low
        queue_name = Hyacinth::Queue::DIGITAL_OBJECT_IMPORT_LOW
      when :medium
        queue_name = Hyacinth::Queue::DIGITAL_OBJECT_IMPORT_MEDIUM
      when :high
        queue_name = Hyacinth::Queue::DIGITAL_OBJECT_IMPORT_HIGH
      else
        raise 'Invalid priority: ' + priority.inspect
      end

      ProcessDigitalObjectImportJob.set(queue: queue_name).perform_later(digital_object_import_id)
    else
      ProcessDigitalObjectImportJob.perform_now(digital_object_import_id)
    end
  end

  def self.export_search_results_to_csv(csv_export_id)
    if HYACINTH[:queue_long_jobs]
      ExportSearchResultsToCsvJob.perform_later(csv_export_id)
    else
      ExportSearchResultsToCsvJob.perform_now(csv_export_id)
    end
  end

  def self.reindex_digital_object(digital_object_pid)
    if HYACINTH[:queue_long_jobs]
      ReindexDigitalObjectJob.perform_later(digital_object_pid)
    else
      ReindexDigitalObjectJob.perform_now(digital_object_pid)
    end
  end
end
