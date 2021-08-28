# frozen_string_literal: true

module DigitalObjectConcerns
  module AsJson
    extend ActiveSupport::Concern

    def as_json(options = nil)
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
        'title',
        'primary_project',
        'other_projects',
        'number_of_children',
        'publish_entries'
      ].map { |field_name|
        [field_name, self.send(field_name).as_json(options)]
      }.to_h.merge(
        'parents' => self.parents.map { |parent| { 'uid' => parent.uid } }
      )
    end
  end
end
