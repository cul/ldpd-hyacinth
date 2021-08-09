# frozen_string_literal: true

module Types
  module DigitalObjectInterface
    include Types::BaseInterface
    include Types::Pageable

    description 'A digital object'

    orphan_types Types::DigitalObject::ItemType, Types::DigitalObject::AssetType, Types::DigitalObject::SiteType

    field :id, ID, null: false, method: :uid
    field :doi, String, null: true
    field :state, Enums::DigitalObjectStateEnum, null: false
    field :digital_object_type, Enums::DigitalObjectTypeEnum, null: false
    field :primary_project, ProjectType, null: false
    field :other_projects, [ProjectType], null: false
    field :identifiers, [String], null: true
    field :descriptive_metadata, GraphQL::Types::JSON, null: false
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
    field :rights, GraphQL::Types::JSON, null: false

    field :title, String, null: false, method: :generate_title
    field :number_of_children, Integer, null: false
    field :resources, [ResourceWrapperType], null: false

    def publish_entries
      object.publish_entries.map { |k, h| { publish_target_string_key: k }.merge(h) }
    end

    def resources
      object.resources.map do |resource_name, resource|
        {
          'id' => resource_name,
          'display_label' => resource_name.humanize.split(' ').map(&:capitalize).join(' '),
          'ui_deletable' => (resource_name != object.main_resource_name),
          'resource' => resource
        }
      end
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
