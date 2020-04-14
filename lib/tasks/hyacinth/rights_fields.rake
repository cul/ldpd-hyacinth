# frozen_string_literal: true

namespace :hyacinth do
  namespace :rights_fields do
    desc 'Load rights fields'
    task load: :environment do
      Hyacinth::DynamicFieldsLoader.load_rights_fields!
      Rake::Task["hyacinth:rights_fields:load_vocabularies"].invoke
    end

    desc 'Load vocabularies needed by rights fields'
    task load_vocabularies: :environment do
      [
        { label: 'Geonames', string_key: 'geonames' },
        { label: 'Rights Statement', string_key: 'rights_statement' },
        { label: 'Name', string_key: 'name' },
        { label: 'Location', string_key: 'location' },
      ].each { |args| Vocabulary.find_or_create_by!(**args) }
    end
  end
end
