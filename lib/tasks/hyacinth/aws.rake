namespace :hyacinth do
  namespace :aws do
    task :restore_archived_s3_objects => :environment do
      if ENV['PIDS'].present?
        pids = ENV['PIDS'].split(',')
      elsif ENV['PIDLIST'].present?
        pids = open(ENV['PIDLIST'],'r').map(&:strip)
      else
        puts 'Error: Please supply a value for PIDS (one or more comma-separated Hyacinth PIDs)'
        next
      end

      pids.each_with_index do |pid|
        print "Checking #{pid}... "

        dobj = DigitalObject::Base.find(pid)
        raise "Only Assets can be restored.  Type of digital object with PID #{pid} is: #{dobj.class.name}" unless dobj.is_a?(DigitalObject::Asset)

        location_uri = dobj.location_uri_for_resource(DigitalObject::Asset::MAIN_RESOURCE_NAME)
				storage_object = Hyacinth::Storage.storage_object_for(location_uri)
				if storage_object.is_a?(Hyacinth::Storage::S3Object)
					# NOTE: storage_object.s3_object.restore will return nil if the object has not been restored yet,
					# but it will return a string if a restore operation has already been run on the object and it is
					# in the process of being restored.
					if ['ARCHIVE_ACCESS', 'DEEP_ARCHIVE_ACCESS'].include?(storage_object.s3_object.archive_status)
						if storage_object.s3_object.restore.nil?
							puts "Need to restore object at: #{storage_object.location_uri}"
							puts "---> Restoring archived object..."
							bucket_name = storage_object.s3_object.bucket_name
							key = storage_object.s3_object.key
							# Make sure that bucket_name and key aren't blank.  They shouldn't ever be blank at this point in the
							# code, but we want to make sure not to call restore if either of them somehow are blank.
							raise if bucket_name.blank? || key.blank?

							begin
								storage_object.s3_object.restore_object({
									bucket: bucket_name,
									key: key,
									# For an object in Intelligent Tiering Archive Instant storage, we just pass an empty hash here.
									# No further configuration is needed.
									restore_request: {}
								})
                if storage_object.s3_object.archive_status == 'ARCHIVE_ACCESS'
								  puts "---> Object restoration request submitted!  The object should be available within 3-5 hours because it was in the ARCHIVE_ACCESS tier."
                else
                  puts "---> Object restoration request submitted!  The object should be available within 12 hours because it was in the DEEP_ARCHIVE_ACCESS tier."
                end
							rescue Aws::S3::Errors::ServiceError => e
								puts "---> An unexpected error occurred while attempting to restore the object: #{e.message}"
							end
						else
							puts "---> A restore request has already been made for this object and restoration is in progress: #{storage_object.s3_object.restore}"
						end
					else
						puts "---> Object is not currently in ARCHIVE_ACCESS or DEEP_ARCHIVE_ACCESS state, so we will not make any changes."
					end

					# puts "Do we need to restore this object?"
				elsif storage_object.is_a?(Hyacinth::Storage::FileObject)
					puts "No need to restore this object because it's available on the local filesystem."
				else
					puts "Ignoring unknown object type: #{storage_object.class.name}"
				end
      end
    end
  end
end
