# frozen_string_literal: true

namespace :hyacinth do
  task reindex: :environment do
    DigitalObjectRecord.find_in_batches(batch_size: (ENV['BATCH_SIZE'] || 1000).to_i) do |records|
      records.each do |record|
        begin
          ::DigitalObject::Base.find(record.uid).index(false)
        rescue => e
          puts "Error while reindexing #{record.uid}. See raised error below:"
          raise e
        end
      end
      Hyacinth::Config.digital_object_search_adapter.solr.commit
    end
  end

  task purge_all_digital_objects: :environment do
    puts Rainbow("This will delete ALL digital objects in Rails.env #{Rails.env} and cannot be undone. Are you sure you want to do this? (yes/no)").red.bright
    print '> '
    response = ENV['yes'] || STDIN.gets.chomp

    if response != 'yes'
      puts 'Aborting because "yes" was not entered.'
      next
    end

    puts 'Running!'

    DigitalObjectRecord.find_in_batches(batch_size: (ENV['BATCH_SIZE'] || 1000).to_i) do |records|
      records.each do |record|
        dobj = ::DigitalObject::Base.find(record.uid)

        # Clear dynamic_field_data and rights to reduce likelihood of data issues during
        # destroy operation that runs before purge.
        dobj.assign_attributes(
          {
            'dynamic_field_data' => {},
            'rights' => {}
          },
          merge_dynamic_field_data: false,
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
