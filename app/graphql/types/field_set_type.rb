module Types
  class FieldSetType < Types::BaseObject
    description 'A field set'

    field :id, ID, null: false
    field :display_label, String, null: false
  end
end
