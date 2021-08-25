# frozen_string_literal: true

module Mutations
  module DigitalObject
    class UpdateChildStructure < Mutations::BaseMutation
      argument :parent_id, String, "parent object of children being reordered", required: true
      argument :ordered_children, [String], required: true

      field :parent, Types::DigitalObject::ItemType, null: true
      field :user_errors, [Types::Errors::FieldedInput], null: false

      def resolve(parent_id:, ordered_children:)
        # This should be an all or nothing update
        ActiveRecord::Base.transaction do
          parent = ::DigitalObject.find_by_uid(parent_id)
          ability_authorize! :update, parent
          ordered_children.each do |ordered_child|
            ParentChildRelationship.where(parent_id: parent_id, id: ordered_child.uid).update(sort_order: ordered_child.sort_order)
          end
          # Successful creation
          {
            parent: parent
          }
        end
      end
    end
  end
end
