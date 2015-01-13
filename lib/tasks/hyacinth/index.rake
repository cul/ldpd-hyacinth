namespace :hyacinth do

  namespace :index do

    task :reindex => :environment do

      # Delete only docs that have the hyacinth_type_sim field.
      # Doing this so that we don't interfere with other docs if
      # this solr core is also used for non-Hyacinth-managed things.
      Hyacinth::Utils::SolrUtils.solr.delete_by_query 'hyacinth_type_sim:["" TO *]'

      # Go through all known DigitalObjectRecords in the DB and reindex them.
      # Do this in batches so that we don't return data for millions of records, all at once.

      total = DigitalObjectRecord.count
      puts "Reindexing #{total} Digital #{total == 1 ? 'Object' : 'Objects'}..."
      progressbar = ProgressBar.create(:title => "Reindex", :starting_at => 0, :total => DigitalObjectRecord.count, :format => '%a |%b>>%i| %p%% %c/%C %t')

      DigitalObjectRecord.find_each(batch_size: 500) do |digital_object_record|
        DigitalObject::Base.find(digital_object_record.pid).update_index(false) # Passing false here so that we don't do one solr commit per update
        progressbar.increment
      end

      Hyacinth::Utils::SolrUtils.solr.commit # Only commit at the end
      progressbar.finish

      puts "Done!"

    end

  end

end
