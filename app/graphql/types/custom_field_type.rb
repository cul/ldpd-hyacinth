module Types
  class CustomFieldType < Types::BaseObject
    # description 'A CanCan Rule'
    field :field, String, null: false
    field :value, String, null: true
  end
end
