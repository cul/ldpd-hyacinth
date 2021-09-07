# frozen_string_literal: true

module Mutations
  module DigitalObject
    class UpdateChildStructure < Mutations::BaseMutation
      argument :parent_uid, String, "parent object of children being reordered", required: true
      argument :ordered_children, [Inputs::ChildStructureInput], required: true

      field :parent, Types::DigitalObjectInterface, null: true

      def resolve(parent_uid:, ordered_children:)
        parent = ::DigitalObject.find_by_uid!(parent_uid)
        ability.authorize! :update, parent

        # This should be an all or nothing update
        ActiveRecord::Base.transaction do
          ordered_children.each do |ordered_child|
            child = ::DigitalObject.find_by_uid!(ordered_child.uid)
            ParentChildRelationship.where(parent_id: parent.id,
              child_id: child.id).update(sort_order: ordered_child.sort_order)
          end
        end

        {
          parent: parent
        }
      end
    end
  end
end
