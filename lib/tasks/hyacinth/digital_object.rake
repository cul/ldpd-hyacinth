require 'thread/pool'

namespace :hyacinth do

  namespace :digital_object do

    # Purge COMPLETELY eliminates records (in the DB, in Fedora and in Solr)
    # This is much more extreme than a regular delete (in which a record is marked as deleted,
    # but not actually erased from existence)
    task :purge => :environment do

      if ENV['PIDS'].present?
        pids = ENV['PIDS'].split(',')
      else
        puts 'Error: Please supply a value for PIDS (one or more comma-separated Hyacinth PIDs)'
        next
      end

      number_of_records_deleted = 0
      number_of_records_that_had_already_been_deleted = 0
      number_of_records_that_could_not_be_deleted = 0

      pids.each_with_index {|pid, i|

        record_was_already_deleted = true
        fedora_rest_client_unauthorized_error_message = nil

        begin
          # Delete DigitalOject the normal way to trigger delete cleanup processes
          digital_object = DigitalObject::Base.find(pid)
          digital_object.destroy
          record_was_already_deleted = false
        rescue Hyacinth::Exceptions::DigitalObjectNotFoundError, ActiveFedora::ObjectNotFoundError, TZInfo::InvalidTimezoneIdentifier => e
          # If the record wasn't found, silently skip this step.  Fedora object must have already been deleted.
        rescue RestClient::Unauthorized => e
          fedora_rest_client_unauthorized_error_message = e.message
        end

        # Remove from solr
        Hyacinth::Utils::SolrUtils.solr.delete_by_query "pid:#{pid.gsub(':','\:')}"

        # Delete from Fedora
        begin
          obj = ActiveFedora::Base.find(pid)
          obj.delete
          record_was_already_deleted = false
        rescue ActiveFedora::ObjectNotFoundError => e
          # If the record wasn't found, silently skip this step.  Fedora object must have already been deleted.
        rescue RestClient::Unauthorized => e
          fedora_rest_client_unauthorized_error_message = e.message
        end

        # Delete actual db record
        digital_object_record = DigitalObjectRecord.find_by(pid: pid)
        if digital_object_record.nil?
          # Silently handle nil record case.  Already deleted.
        else
          digital_object_record.destroy
          record_was_already_deleted = false
        end

        ###

        if fedora_rest_client_unauthorized_error_message
          puts "Could not access #{pid} in Fedora. Error message: #{e.message}"
          number_of_records_that_could_not_be_deleted += 1
          record_was_already_deleted = false
        end

        if record_was_already_deleted
          number_of_records_that_had_already_been_deleted += 1
        elsif ! fedora_rest_client_unauthorized_error_message.nil?
          # Nothing
        else
          number_of_records_deleted += 1
        end

        puts "Purged #{i+1} of #{pids.length} [#{pid}]"
      }

      Hyacinth::Utils::SolrUtils.solr.commit # Only commit at the end

      puts "Purged #{number_of_records_deleted + number_of_records_that_had_already_been_deleted} " + ((number_of_records_deleted + number_of_records_that_had_already_been_deleted) == 1 ? 'record' : 'records') + '.'
      puts "Note: #{number_of_records_that_had_already_been_deleted} " + (number_of_records_that_had_already_been_deleted == 1 ? 'record' : 'records') + ' were already nonexistent.' if number_of_records_that_had_already_been_deleted > 1
      puts "Note: #{number_of_records_that_could_not_be_deleted} " + (number_of_records_that_could_not_be_deleted == 1 ? 'record' : 'records') + ' could not be deleted.' if number_of_records_that_could_not_be_deleted > 1
    end


  end

end
