# frozen_string_literal: true

namespace :hyacinth do
  desc "Reindexes all digital objects"
  task reindex: :environment do
    Hyacinth::Config.digital_object_search_adapter.commit_after_change = false
    DigitalObject.find_each(batch_size: (ENV['BATCH_SIZE'] || 200).to_i) do |digital_object|
      digital_object.index
    rescue
      puts "Error while reindexing #{record.uid}. See raised error below:"
      raise # re-raise original exception
    ensure
      Hyacinth::Config.digital_object_search_adapter.commit # commit whatever we were able to reindex
    end
  end

  task purge_all_digital_objects: :environment do
    puts Rainbow("This will delete ALL digital objects in the selected Rails environment (#{Rails.env}) and cannot be undone. "\
      "Please confirm that you want to continue by typing in the selected Rails environment (#{Rails.env}):").red.bright
    print '> '
    response = ENV['rails_env_confirmation'] || $stdin.gets.chomp

    if response != Rails.env
      puts "Aborting because \"#{Rails.env}\" was not entered."
      next
    end

    puts 'Running!'

    DigitalObject.find_each(batch_size: (ENV['BATCH_SIZE'] || 200).to_i) do |digital_object|
      # Clear descriptive_metadata and rights to reduce likelihood of data issues during
      # destroy operation that runs before purge.
      digital_object.assign_attributes(
        {
          'descriptive_metadata' => {},
          'rights' => {}
        },
        false,
        false
      )
      begin
        digital_object.remove_all_children!
        digital_object.destroy
        puts "Purged: #{digital_object.uid}"
      rescue Hyacinth::Exceptions::NotFound
        puts "Purged #{digital_object.uid} (but no associated metadata was found)"
      end
    end
    Hyacinth::Config.digital_object_search_adapter.clear_index
    puts 'Done!'
  end
end
