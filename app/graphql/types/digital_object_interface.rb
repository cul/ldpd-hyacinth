module Types
  module DigitalObjectInterface
    include Types::BaseInterface
    description 'A digital object'

    orphan_types Types::DigitalObject::ItemType, Types::DigitalObject::AssetType, Types::DigitalObject::SiteType

    field :id, ID, null: false, method: :uid
    field :serialization_version, String, null: false
    field :doi, String, null: true
    field :state, String, null: false # can be an enum
    field :digital_object_type, String, null: false # can be an enum type
    field :projects, [ProjectType], null: false
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

    def publsh_entries
      object.publish_entries.map { |k, h| { publish_target_string_key: k }.merge(h) }
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
