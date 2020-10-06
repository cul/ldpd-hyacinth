# frozen_string_literal: true

module DigitalObjectConcerns
  module AsJson
    extend ActiveSupport::Concern

    def as_json(options = {})
      [
        'uid',
        'digital_object_type',
        'doi',
        'state',
        'created_by',
        'created_at',
        'updated_by',
        'updated_at',
        'first_published_at',
        'preserved_at',
        'first_preserved_at',
        'identifiers',
        'descriptive_metadata',
        'rights',
        'primary_project',
        'other_projects',
        'number_of_children',
        'publish_entries'
      ].map { |field_name|
        [field_name, self.send(field_name)]
      }.to_h.merge(
        {
          'parent_digital_objects' => self.parent_uids.map { |parent_uid| { 'uid' => parent_uid } }
        }
      )
    end
  end
end
