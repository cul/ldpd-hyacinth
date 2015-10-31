class ProcessDigitalObjectImportJob

  @queue = :ids_of_digital_object_imports

  def self.perform(doi_id)

    puts "ProcessDigitalObjectImportJob: About to process DigitalObjectImport instance"
    puts "using the passed-in id. Id is " + doi_id.to_s + '.'

    # Retrieve DigitalObjectImport instance from table

    digital_object_import = DigitalObjectImport.find(doi_id)

    # fcd1: add error processing if no DigitalObjectImport instance found at the given id

    puts digital_object_import.inspect

    # for now, just change the status to success
    digital_object_import.success!

    puts digital_object_import.inspect

    puts "Done Processing"

  end

end
