# frozen_string_literal: true

class BatchImportStartJob
  @queue = :batch_import_setup

  # Uses a newly-created BatchImport to create a bunch of corresponding DigitalObjectImports,
  # and then queues all immediately-processable DigitalObjectImports as DigitalObjectImportJobs.
  def self.perform(batch_import_id)
    batch_import = BatchImport.find(batch_import_id)

    process_csv_file_if_present(batch_import)

    # Find all DigitalObjectImports in this batch that have no prerequisites so we can enqueue them
    # for immediate background job processing.
    no_prerequisite_digital_object_imports_query = DigitalObjectImport.select(:id).left_outer_joins(:import_prerequisites).where(
      import_prerequisites: { id: nil }
    )
    # Batch mark these objects as queued, in advance of us enqueueing them
    no_prerequisite_digital_object_imports_query.update_all(status: 'queued')
    # Enqueue processing jobs for these objects
    no_prerequisite_digital_object_imports_query.pluck(:id).each do |digital_object_import_id|
      Resque.enqueue(DigitalObjectImportProcessingJob, digital_object_import_id)
    end
  rescue StandardError => e
    handle_job_error(batch_import, e)
  end

  def self.process_csv_file_if_present(batch_import)
    return unless batch_import.file_location.present?

    Hyacinth::Config.batch_import_storage.with_readable_tempfile(batch_import.file_location) do |csv_file|
      row_prerequisite_map = Hyacinth::BatchImport::IndexPrerequisiteMap.generate(csv_file)
      row_numbers_to_digital_object_import_ids = {}

      # Generate DigitalObjectImports for each row
      BatchImport.csv_file_to_hierarchical_json_hash(csv_file) do |json_hash_for_row, csv_row_number|
        row_numbers_to_digital_object_import_ids[csv_row_number] = create_pending_digital_object_import!(batch_import, json_hash_for_row, csv_row_number).id
      end

      row_prerequisite_map.each do |row_number, prerequisite_row_numbers|
        digital_object_import_id = row_numbers_to_digital_object_import_ids[row_number]
        prerequisite_row_numbers.each do |prerequisite_row_number|
          prerequisite_digital_object_import_id = row_numbers_to_digital_object_import_ids[prerequisite_row_number]
          ImportPrerequisite.create!(
            batch_import: batch_import,
            digital_object_import_id: digital_object_import_id,
            prerequisite_digital_object_import_id: prerequisite_digital_object_import_id
          )
        end
      end
    end
  end

  # Create a pending DigitalObjectImport from json_hash and link it to the parent batch_import
  # @return [DigitalObjectImport] The newly created DigitalObjectImport.
  def self.create_pending_digital_object_import!(batch_import, json_hash_for_row, csv_row_number)
    DigitalObjectImport.create!(
      batch_import: batch_import,
      status: 'pending',
      index: csv_row_number,
      digital_object_data: JSON.generate(json_hash_for_row)
    )
  end

  def self.handle_job_error(batch_import, error)
    batch_import.setup_errors <<
      error.message + "\n\n"\
      "See application error log for more details.\n"\
      "Message generated at #{Time.current}"
    Rails.logger.error(error.message + "\n" + error.backtrace.join("\n"))
    # Mark as cancelled, to indicate that this job isn't running and to limit the number
    # of DigitalObjectImports that might be running (if any were successfully queued before
    # the error came up.
    batch_import.cancelled = true
    batch_import.save!
  end
end
