# frozen_string_literal: true

module DigitalObjectConcerns
  module AttributeAssignment
    module ParentUids
      extend ActiveSupport::Concern
      # TODO: Test these methods via shared_example (https://stackoverflow.com/questions/16525222/how-to-test-a-concern-in-rails)

      def assign_parent_uids(digital_object_data)
        return unless digital_object_data.key?('parent_digital_objects')

        new_set_of_uids = Set.new
        new_set_of_identifiers = Set.new

        # Get uids and identifiers
        digital_object_data['parent_digital_objects'].each do |dod_parent_digital_object|
          if dod_parent_digital_object['uid'].present?
            new_set_of_uids << dod_parent_digital_object['uid']
          elsif dod_parent_digital_object['identifier'].present?
            new_set_of_identifiers << dod_parent_digital_object['identifier']
          else
            raise Hyacinth::Exceptions::NotFound, "Could not find parent digital object using find criteria: #{dod_parent_digital_object.inspect}"
          end
        end

        # Resolve any identifiers to uids and add them to new_set_of_uids
        new_set_of_identifiers.each do |identifier|
          uids = Hyacinth::Config.digital_object_search_adapter.identifier_to_uids(identifier, retry_with_delay: 5.seconds)

          if uids.blank?
            raise Hyacinth::Exceptions::NotFound,
                  "Could not find parent digital object using identifier: #{identifier}"
          elsif uids.length > 1
            raise Hyacinth::Exceptions::NotFound,
                  "Ambiguous parent linkage. Found more than one UID for identifier #{identifier}. UIDS: #{uids.join(', ')}"
          end
          new_set_of_uids << uids.first
        end

        # Add new UIDs that don't already exist in set of parents
        (new_set_of_uids - parent_uids).each do |uid|
          add_parent_uid(uid)
        end

        # Remove omitted UIDs that currently exist in set of parents
        (parent_uids - new_set_of_identifiers.to_a).each do |uid|
          remove_parent_uid(uid)
        end
      end

      def add_parent_uid(uid)
        @parent_uids_to_add << uid
      end

      def remove_parent_uid(uid)
        @parent_uids_to_remove << uid
      end
    end
  end
end
