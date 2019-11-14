module Types
  class CustomFieldDefinitionType < Types::BaseObject
    description 'A custom field definition'

    field :field_key, ID, null: false
    field :label, String, null: false
    field :data_type, String, null: false # Enum string, integer, boolean
  end
end
