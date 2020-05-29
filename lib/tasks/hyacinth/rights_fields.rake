# frozen_string_literal: true

namespace :hyacinth do
  namespace :rights_fields do
    desc 'Load rights fields'
    task load: :environment do
      Hyacinth::DynamicFieldsLoader.load_rights_fields!(load_vocabularies: true)
    end
  end
end
