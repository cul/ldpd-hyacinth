# frozen_string_literal: true

module Types
  module DigitalObjectInterface
    include Types::BaseInterface
    include Types::Pageable

    description 'A digital object'

    TITLE_DYNAMIC_FIELD_GROUP_NAME = 'title'
    TITLE_SORT_PORTION_DYNAMIC_FIELD_NAME = 'sort_portion'
    TITLE_NON_SORT_PORTION_DYNAMIC_FIELD_NAME = 'non_sort_portion'

    orphan_types Types::DigitalObject::ItemType, Types::DigitalObject::AssetType, Types::DigitalObject::SiteType

    field :id, ID, null: false, method: :uid
    field :serialization_version, String, null: false
    field :doi, String, null: true
    field :state, Enums::DigitalObjectStateEnum, null: false
    field :digital_object_type, Enums::DigitalObjectTypeEnum, null: false
    field :primary_project, ProjectType, null: false
    field :other_projects, [ProjectType], null: false
    field :identifiers, [String], null: true
    field :dynamic_field_data, GraphQL::Types::JSON, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :created_by, UserType, null: true
    field :updated_by, UserType, null: true
    field :first_published_at, GraphQL::Types::ISO8601DateTime, null: true
    field :first_preserved_at, GraphQL::Types::ISO8601DateTime, null: true
    field :preserved_at, GraphQL::Types::ISO8601DateTime, null: true
    field :parents, [DigitalObjectInterface], null: true
    field :structured_children, DigitalObject::StructuredChildrenType, null: true
    field :publish_entries, [DigitalObject::PublishEntryType], null: true
    field :optimistic_lock_token, String, null: false

    field :title, String, null: false
    field :number_of_children, Integer, null: false
    field :resources, [ResourceType], null: false

    def publish_entries
      object.publish_entries.map { |k, h| { publish_target_string_key: k }.merge(h) }
    end

    def title
      DigitalObjectInterface.title_for(object)
    end

    def resources
      object.resources.map do |resource_name, resource|
        {
          'id' => resource_name,
          'display_label' => resource_name.humanize.split(' ').map(&:capitalize).join(' ')
        }.merge(
          resource.as_json
        )
      end
    end

    def self.title_for(object, sortable = false)
      val = '[No Title]'

      title_field_group = object.dynamic_field_data[TITLE_DYNAMIC_FIELD_GROUP_NAME]
      if title_field_group.present? && (title_field = title_field_group[0]).present?
        val = title_field[TITLE_SORT_PORTION_DYNAMIC_FIELD_NAME]
        non_sort_portion = title_field[TITLE_NON_SORT_PORTION_DYNAMIC_FIELD_NAME]
        val = "#{non_sort_portion} #{val}" if non_sort_portion && !sortable
      end

      val
    end

    def number_of_children
      object.structured_children['structure'].length
    end

    definition_methods do
      def resolve_type(object, _context)
        case object
        when ::DigitalObject::Item
          Types::DigitalObject::ItemType
        when ::DigitalObject::Asset
          Types::DigitalObject::AssetType
        when ::DigitalObject::Site
          Types::DigitalObject::SiteType
        else
          raise "Unexpected DigitalObject: #{object.inspect}"
        end
      end
    end
  end
end
