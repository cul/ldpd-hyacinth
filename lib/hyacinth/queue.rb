module Hyacinth::Queue

  DIGITAL_OBJECT_IMPORT = :digital_object_import

  QUEUES_IN_DESCENDING_PRIORITY_ORDER = [DIGITAL_OBJECT_IMPORT]
  
  def self.process_digital_object_import(conditions)
    if HYACINTH['queue_long_jobs']
			Resque.enqueue(ProcessDigitalObjectImportJob, conditions)
		else
			ProcessDigitalObjectImportJob.perform(conditions)
		end
  end

end
