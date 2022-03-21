# frozen_string_literal: true

module DigitalObjectConcerns
  module ParentChildBehavior
    extend ActiveSupport::Concern

    included do
      has_many :parent_directed_parent_child_relationships, class_name: 'ParentChildRelationship', foreign_key: 'child_id', dependent: :destroy
      has_many :child_directed_parent_child_relationships, class_name: 'ParentChildRelationship', foreign_key: 'parent_id', dependent: :destroy

      attr_reader :parents_to_add
      attr_reader :parents_to_remove
      attr_reader :children_to_add
      attr_reader :children_to_remove

      after_initialize do |_digital_object|
        @parents_to_add = []
        @parents_to_remove = []
        @children_to_add = []
        @children_to_remove = []
      end

      after_save :persist_parent_child_updates
      after_commit :clear_pending_parent_child_additions_and_removals
      after_reload :clear_instance_parents_children_cache
      before_destroy :remove_all_parents!
      before_destroy :abort_destroy_if_children_present, prepend: true # must run before other before_destroy callbacks
      after_destroy :clear_instance_parents_children_cache
    end

    def parents
      # The returned array must be frozen.  We don't want modifications to be made directly to this array.
      @parents ||= ordered_digital_objects_for_ids(currently_persisted_parent_ids).freeze
    end

    def children
      # The returned array must be frozen.  We don't want modifications to be made directly to this array.
      @children ||= ordered_digital_objects_for_ids(currently_persisted_child_ids).freeze
    end

    def remove_all_parents!
      ParentChildRelationship.where(child: self).delete_all
      @parents = nil
    end

    def remove_all_children!
      ParentChildRelationship.where(parent: self).delete_all
      @children = nil
    end

    # When you only need the UIDs of the parents, this is more efficient than instantiating all parents
    def currently_persisted_parent_uids
      DigitalObject.where(id: currently_persisted_parent_ids).pluck(:uid)
    end

    private

      # Returns an array of DigitalObject instances for the given array of ordered_ids, ordered by
      # the id order specified by ordered_ids.
      def ordered_digital_objects_for_ids(ordered_ids)
        digital_objects = DigitalObject.where(id: ordered_ids).to_a
        id_order_map = {}
        ordered_ids.each_with_index { |id, index| id_order_map[id] = index }
        digital_objects.sort_by! { |digital_object| id_order_map[digital_object.id] }
        digital_objects
      end

      # Ensures that all add/remove lists are unique
      def eliminate_duplicate_parent_child_additions!
        parents_to_add.uniq!
        children_to_add.uniq!
        parents_to_remove.uniq!
        children_to_remove.uniq!
      end

      # Verifies that the same digital object doesn't exist in both the add and remove lists.
      # We treat this kind of duplication as something that should just be cancelled out,
      # as if neither of the values were present in the add or remove lists.
      def eliminate_negated_parent_child_additions_and_removals!
        (parents_to_add & parents_to_remove).tap do |negated_parents|
          parents_to_add.reject! { |dobj| negated_parents.include?(dobj) }
          parents_to_remove.reject! { |dobj| negated_parents.include?(dobj) }
        end
        (children_to_add & children_to_remove).tap do |negated_children|
          children_to_add.reject! { |dobj| negated_children.include?(dobj) }
          children_to_remove.reject! { |dobj| negated_children.include?(dobj) }
        end
      end

      def abort_destroy_if_children_present
        self.errors.add(:children, 'Cannot destroy digital object because it has children.  Disconnect or delete the child digital objects first.')
        throw(:abort) if children.present?
      end

      def clear_instance_parents_children_cache
        @parents = nil
        @children = nil
      end

      def parent_child_updates_pending?
        return true if parents_to_add.present?
        return true if parents_to_remove.present?
        return true if children_to_add.present?
        return true if children_to_remove.present?
        false
      end

      def clear_pending_parent_child_additions_and_removals
        parents_to_add.clear
        parents_to_remove.clear
        children_to_add.clear
        children_to_remove.clear
      end

      def apply_parent_removals!
        return if parents_to_remove.blank?
        ParentChildRelationship.where(child: self, parent: parents_to_remove).delete_all
        @parents = nil # clear parent instance variable cache
      end

      def apply_child_removals!
        return if children_to_remove.blank?
        ParentChildRelationship.where(parent_id: self.id, child_id: children_to_remove).delete_all
        @children = nil # clear children instance variable cache
      end

      def apply_parent_additions!
        return if parents_to_add.blank?
        # Perform additions, appending new entries so they're ordered last among existing objects.
        parents_to_add.each do |parent_to_add|
          order = (ParentChildRelationship.where(parent: parent_to_add).maximum(:sort_order) || -1) + 1
          ParentChildRelationship.create!(
            parent: parent_to_add,
            child: self,
            sort_order: order
          )
        end
        @parents = nil # clear parent instance variable cache
      end

      def apply_child_additions!
        return if children_to_add.blank?
        # Perform additions, appending new entries so they're ordered last among existing objects.
        order = (ParentChildRelationship.where(parent: self).maximum(:sort_order) || -1) + 1
        children_to_add.each do |child_to_add|
          ParentChildRelationship.create!(
            parent: self,
            child: child_to_add,
            sort_order: order
          )
          order += 1
        end
        @children = nil # clear child instance variable cache
      end

      def persist_parent_child_updates
        return unless parent_child_updates_pending?

        # Clean up the add/removal lists in case any of the intended changes already exist.
        # We'll do id comparisons in order to avoid loading all parent and child objects.
        existing_parent_ids = currently_persisted_parent_ids
        existing_child_ids = currently_persisted_child_ids

        eliminate_duplicate_parent_child_additions!

        parents_to_add.reject! { |dobj| existing_parent_ids.include?(dobj.id) }
        children_to_add.reject! { |dobj| existing_child_ids.include?(dobj.id) }
        parents_to_remove.select! { |dobj| existing_parent_ids.include?(dobj.id) }
        children_to_remove.select! { |dobj| existing_child_ids.include?(dobj.id) }

        eliminate_negated_parent_child_additions_and_removals!

        # Perform removals
        apply_parent_removals!
        apply_child_removals!
        apply_parent_additions!
        apply_child_additions!
      end

      def currently_persisted_parent_ids
        ActiveRecord::Base.uncached do
          # sort order doesn't matter here, but it should be consistent
          parent_directed_parent_child_relationships.order(:id).pluck(:parent_id)
        end
      end

      def currently_persisted_child_ids
        ActiveRecord::Base.uncached do
          # sort order matters here!
          child_directed_parent_child_relationships.order(:sort_order).pluck(:child_id)
        end
      end
  end
end
