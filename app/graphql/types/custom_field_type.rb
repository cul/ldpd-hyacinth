module Types
  class CustomFieldType < Types::BaseObject
    description 'A custom field value'

    field :field, String, null: false
    field :value, String, null: true
  end
end
