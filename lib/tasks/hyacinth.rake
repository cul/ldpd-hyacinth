# frozen_string_literal: true

namespace :hyacinth do
  task reindex: :environment do
    DigitalObjectRecord.find_in_batches(batch_size: (ENV['BATCH_SIZE'] || 1000).to_i) do |records|
      records.each { |record| ::DigitalObject::Base.find(record.uid).index(false) }
      Hyacinth::Config.digital_object_search_adapter.solr.commit
    end
  end

  task purge_all_digital_objects: :environment do
    puts Rainbow("This will delete ALL digital objects in Rails.env #{Rails.env} and cannot be undone. Are you sure you want to do this? (yes/no)").red.bright
    print '> '
    response = STDIN.gets.chomp

    if response != 'yes'
      puts 'Aborting because "yes" was not entered.'
      next
    end

    puts 'Running!'

    DigitalObjectRecord.find_in_batches(batch_size: (ENV['BATCH_SIZE'] || 1000).to_i) do |records|
      records.each do |record|
        dobj = ::DigitalObject::Base.find(record.uid)

        # Clear descriptive and rights data to reduce likelihood of data issues during
        # destroy operation that runs before purge.
        dobj.assign_attributes(
          {
            'descriptive' => {},
            'rights' => {}
          },
          merge_descriptive: false,
          merge_rights: false
        )
        begin
          dobj.purge!
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
