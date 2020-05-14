# frozen_string_literal: true

namespace :hyacinth do
  desc "Reindexes all digital objects"
  task reindex: :environment do
    DigitalObjectRecord.find_in_batches(batch_size: (ENV['BATCH_SIZE'] || 1000).to_i) do |records|
      records.each do |record|
        ::DigitalObject::Base.find(record.uid).index(false)
      rescue
        puts "Error while reindexing #{record.uid}. See raised error below:"
        raise
      end
      Hyacinth::Config.digital_object_search_adapter.solr.commit
    end
  end

  task purge_all_digital_objects: :environment do
    puts Rainbow("This will delete ALL digital objects in the selected Rails environment (#{Rails.env}) and cannot be undone. "\
      "Please confirm that you want to continue by typing in the selected Rails environment (#{Rails.env}):").red.bright
    print '> '
    response = ENV['rails_env_confirmation'] || STDIN.gets.chomp

    if response != Rails.env
      puts "Aborting because \"#{Rails.env}\" was not entered."
      next
    end

    puts 'Running!'

    DigitalObjectRecord.find_in_batches(batch_size: (ENV['BATCH_SIZE'] || 1000).to_i) do |records|
      records.each do |record|
        dobj = ::DigitalObject::Base.find(record.uid)

        # Clear descriptive_metadata and rights to reduce likelihood of data issues during
        # destroy operation that runs before purge.
        dobj.assign_attributes(
          {
            'descriptive_metadata' => {},
            'rights' => {}
          },
          merge_descriptive_metadata: false,
          merge_rights: false
        )
        begin
          dobj.purge!(skip_child_check: true)
          puts "Purged: #{record.uid}"
        rescue Hyacinth::Exceptions::NotFound
          puts "Purged #{record.uid} (but no associated metadata was found)"
        end
        record.destroy
      end
    end
    Hyacinth::Config.digital_object_search_adapter.clear_index
    puts 'Done!'
  end
end
