# frozen_string_literal: true

namespace :hyacinth do
  task reindex: :environment do
    DigitalObjectRecord.find_in_batches(batch_size: (ENV['BATCH_SIZE'] || 1000).to_i) do |records|
      records.each { |record| ::DigitalObject::Base.find(record.uid).index(false) }
      Hyacinth::Config.digital_object_search_adapter.solr.commit
    end
  end
end
